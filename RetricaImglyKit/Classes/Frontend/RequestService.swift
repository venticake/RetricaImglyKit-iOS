//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

/**
 *  A request service is used to perform a get request and hand the data over via block.
 */
@available(iOS 8, *)
@objc(IMGLYRequestServiceProtocol) public protocol RequestServiceProtocol {
    /**
     Used to perform a get request to the given url.

     - parameter url:      The url of the request.
     - parameter cached:   Whether or not the request should be cached.
     - parameter callback: Called with the result of the request.
     */
    func get(url: NSURL, cached: Bool, callback: (NSData?, NSError?) -> Void)
}

/**
 *  The `RequestService` is out to perform a get request and hand the data over via block.
 */
@available(iOS 8, *)
@objc(IMGLYRequestService) public class RequestService: NSObject, RequestServiceProtocol {

    /**
     Performs a get request.

     - parameter url:  A url as `String`.
     - parameter callback: A callback that gets the retieved data or the occured error.
     */
    public func get(url: NSURL, cached: Bool, callback: (NSData?, NSError?) -> Void) {
        if cached {
            getCached(url, callback: callback)
        } else {
            getUncached(url, callback: callback)
        }
    }

    private func getCached(url: NSURL, callback: (NSData?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        let session  = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }

    private func getUncached(url: NSURL, callback: (NSData?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let session  = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }

        task.resume()
    }
}
