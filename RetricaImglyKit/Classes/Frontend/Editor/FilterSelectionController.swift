//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit

/**
 A `FilterSelectionController` contains everything that is needed to display a list of available filters.
 */
@objc(IMGLYFilterSelectionController) public class FilterSelectionController: NSObject {

    // MARK: - Statics

    private static let FilterCollectionViewCellReuseIdentifier = "FilterCollectionViewCell"
    private static let FilterCollectionViewCellSize = CGSize(width: 64, height: 80)
    private static let FilterActivationDuration = NSTimeInterval(0.15)

    private var thumbnails = [Int: UIImage]()

    // MARK: - Properties

    /// The collection view that presents all available filters.
    public let collectionView: UICollectionView

    /// This block is called when a new photo effect is selected.
    public var selectedBlock: ((PhotoEffect) -> ())?

    /// This block is used to determine the currently applied photo effect.
    public var activePhotoEffectBlock: (() -> (PhotoEffect?))?

    /// This block is used to configure the filter collection view cell.
    public var cellConfigurationClosure: ((FilterCollectionViewCell, PhotoEffect) -> ())?

    private var photoEffectThumbnailRenderer: PhotoEffectThumbnailRenderer?

    // MARK: - Initializers

    /**
    :nodoc:
    */
    public convenience override init() {
        self.init(inputImage: nil)
    }

    /**
     Returns a newly allocated instance of a `FilterSelectionController` using the given input image.

     - parameter inputImage: The input image that should be used to preview the filters.

     - returns: An instance of a `FilterSelectionController`.
     */
    public init(inputImage: UIImage?) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = FilterSelectionController.FilterCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.minimumLineSpacing = 7

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        super.init()

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterSelectionController.FilterCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        let renderer = PhotoEffectThumbnailRenderer(inputImage: inputImage ?? UIImage(named: "nonePreview", inBundle: NSBundle.imglyKitBundle, compatibleWithTraitCollection: nil)!)
        renderer.generateThumbnailsForPhotoEffects(PhotoEffect.allEffects, ofSize: CGSize(width: 64, height: 64)) { thumbnail, index in
            dispatch_async(dispatch_get_main_queue()) {
                self.saveThumbnail(thumbnail, forIndex: index)
            }
        }
    }

    private func saveThumbnail(thumbnail: UIImage, forIndex index: Int) {
        thumbnails[index] = thumbnail

        if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? FilterCollectionViewCell where collectionView.superview != nil {
            cell.imageView.image = thumbnail
            cell.activityIndicator.stopAnimating()
        }
    }

    /**
     Updates the cell selection based on the `activePhotoEffectBlock`.

     - parameter animated: If `true` the selection will be animated.
     */
    public func updateSelectionAnimated(animated: Bool) {
        if let photoEffect = activePhotoEffectBlock?(), index = PhotoEffect.allEffects.indexOf(photoEffect) {
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: animated, scrollPosition: .None)
        }
    }

}

extension FilterSelectionController: UICollectionViewDataSource {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoEffect.allEffects.count
    }

    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilterSelectionController.FilterCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let filterCell = cell as? FilterCollectionViewCell {
            let effectFilter = PhotoEffect.allEffects[indexPath.item]

            if effectFilter == activePhotoEffectBlock?() {
                dispatch_async(dispatch_get_main_queue()) {
                    // Unfortunately this does not work the first time it is called, so we are doing it in the next
                    // layout pass
                    collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                }
            }

            filterCell.accessibilityLabel = effectFilter.displayName
            filterCell.captionLabel.text = effectFilter.displayName

            if let image = thumbnails[indexPath.item] {
                filterCell.imageView.image = image
            } else {
                filterCell.activityIndicator.startAnimating()
            }

            cellConfigurationClosure?(filterCell, effectFilter)
        }

        return cell
    }
}

extension FilterSelectionController: UICollectionViewDelegate {
    /**
     :nodoc:
     */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath) {
            let extendedCellRect = layoutAttributes.frame.insetBy(dx: -60, dy: 0)
            collectionView.scrollRectToVisible(extendedCellRect, animated: true)
        }

        let photoEffect = PhotoEffect.allEffects[indexPath.item]
        selectedBlock?(photoEffect)
    }
}
