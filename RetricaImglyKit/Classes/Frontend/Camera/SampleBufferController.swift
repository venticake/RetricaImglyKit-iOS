//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import AVFoundation
import CoreImage
import GLKit

class SampleBufferController: NSObject {

    // MARK: - Properties

    let videoPreviewView: GLKView
    let ciContext: CIContext
    var photoEffect: PhotoEffect? = PhotoEffect.allEffects.first
    var photoEffectIntensity: CGFloat = 1

    var videoController: VideoController?
    var previewFrameChangedHandler: ((previewFrame: CGRect) -> Void)?

    private(set) var currentPreviewFrame: CGRect? {
        didSet {
            if let currentPreviewFrame = currentPreviewFrame where oldValue != currentPreviewFrame {
                previewFrameChangedHandler?(previewFrame: currentPreviewFrame)
            }
        }
    }

    private(set) var currentVideoDimensions: CMVideoDimensions?

    private var colorCubeData: NSData?
    private lazy var lutConverter = LUTToNSDataConverter(identityLUTAtURL: NSBundle.imglyKitBundle.URLForResource("Identity", withExtension: "png")!)

    // MARK: - Initializers

    init(videoPreviewView: GLKView) {
        self.videoPreviewView = videoPreviewView
        ciContext = CIContext(EAGLContext: self.videoPreviewView.context, options: nil)

        super.init()
    }

}

extension SampleBufferController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }

        let mediaType = CMFormatDescriptionGetMediaType(formatDescription)

        // Handle Audio Recording
        if mediaType == CMMediaType(kCMMediaType_Audio) {
            if let assetWriterAudioInput = videoController?.assetWriterAudioInput where assetWriterAudioInput.readyForMoreMediaData {
                let success = assetWriterAudioInput.appendSampleBuffer(sampleBuffer)
                if !success {
                    videoController?.abortWriting()
                }
            }

            return
        }

        // Handle Video
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

        let sourceImage: CIImage
        if #available(iOS 9.0, *) {
            sourceImage = CIImage(CVImageBuffer: imageBuffer)
        } else {
            sourceImage = CIImage(CVPixelBuffer: imageBuffer as CVPixelBuffer)
        }

        let filteredImage: CIImage
        if let effect = photoEffect, filter = effect.newEffectFilter {

            // If this is a `CIColorCube` or `CIColorCubeWithColorSpace` filter, a `lutURL` is set
            // and no `inputCubeData` was specified, generate new color cube data from the provided
            // LUT
            if let lutURL = effect.lutURL, filterName = effect.CIFilterName where (filterName == "CIColorCube" || filterName == "CIColorCubeWithColorSpace") && effect.options?["inputCubeData"] == nil {
                // Update color cube data if needed
                if lutConverter.lutURL != lutURL || lutConverter.intensity != Float(photoEffectIntensity) {
                    lutConverter.lutURL = effect.lutURL
                    lutConverter.intensity = Float(photoEffectIntensity)
                    colorCubeData = lutConverter.colorCubeData
                }

                filter.setValue(colorCubeData, forKey: "inputCubeData")
            }

            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            filteredImage = filter.outputImage ?? sourceImage
        } else {
            colorCubeData = nil
            filteredImage = sourceImage
        }

        let targetRect = CGRect(x: 0, y: 0, width: videoPreviewView.drawableWidth, height: videoPreviewView.drawableHeight)
        let videoPreviewFrame = sourceImage.extent.rectFittedIntoTargetRect(targetRect, withContentMode: .ScaleAspectFit)

        glClearColor(0, 0, 0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        // Handle Video Recording
        if let videoController = videoController, assetWriter = videoController.assetWriter, assetWriterVideoInput = videoController.assetWriterVideoInput {
            videoController.currentVideoTime = timestamp

            if !videoController.videoWritingStarted {
                videoController.videoWritingStarted = true

                let success = assetWriter.startWriting()
                if !success {
                    videoController.abortWriting()
                    return
                }

                assetWriter.startSessionAtSourceTime(timestamp)
                videoController.videoWritingStartTime = timestamp
            }

            let assetWriterInputPixelBufferAdaptor = videoController.assetWriterInputPixelBufferAdaptor
            if let pixelBufferPool = assetWriterInputPixelBufferAdaptor?.pixelBufferPool {
                var renderedOutputPixelBuffer: CVPixelBuffer?
                let status = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &renderedOutputPixelBuffer)
                if status != 0 {
                    videoController.abortWriting()
                    return
                }

                if let renderedOutputPixelBuffer = renderedOutputPixelBuffer {
                    ciContext.render(filteredImage, toCVPixelBuffer: renderedOutputPixelBuffer)

                    let drawImage = CIImage(CVPixelBuffer: renderedOutputPixelBuffer)
                    ciContext.drawImage(drawImage, inRect: videoPreviewFrame, fromRect: filteredImage.extent)

                    if assetWriterVideoInput.readyForMoreMediaData {
                        assetWriterInputPixelBufferAdaptor?.appendPixelBuffer(renderedOutputPixelBuffer, withPresentationTime: timestamp)
                    }
                }
            }
        } else {
            // Handle Live Preview (no recording session)
            ciContext.drawImage(filteredImage, inRect: videoPreviewFrame, fromRect: filteredImage.extent)
        }

        currentPreviewFrame = videoPreviewFrame
        videoPreviewView.display()
    }
}
