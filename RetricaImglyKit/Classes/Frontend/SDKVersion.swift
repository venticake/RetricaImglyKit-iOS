//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

struct SDKVersion: Comparable, CustomStringConvertible {
    let majorVersion: Int
    let minorVersion: Int
    let patchVersion: Int

    var description: String {
        return "\(majorVersion).\(minorVersion).\(patchVersion)"
    }

    init?(string: String) {
        let versionComponents = string.componentsSeparatedByString(".")

        if versionComponents.count == 1 {
            guard let majorVersion = Int(versionComponents[0]) else {
                return nil
            }

            self.majorVersion = majorVersion
            self.minorVersion = 0
            self.patchVersion = 0
        } else if versionComponents.count == 2 {
            guard let majorVersion = Int(versionComponents[0]), minorVersion = Int(versionComponents[1]) else {
                return nil
            }

            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = 0
        } else if versionComponents.count == 3 {
            guard let majorVersion = Int(versionComponents[0]), minorVersion = Int(versionComponents[1]), patchVersion = Int(versionComponents[2]) else {
                return nil
            }

            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
        } else {
            return nil
        }
    }
}

func == (lhs: SDKVersion, rhs: SDKVersion) -> Bool {
    return (lhs.majorVersion == rhs.majorVersion) && (lhs.minorVersion == rhs.minorVersion) && (lhs.patchVersion == rhs.patchVersion)
}

func < (lhs: SDKVersion, rhs: SDKVersion) -> Bool {
    if lhs.majorVersion < rhs.majorVersion {
        return true
    } else if lhs.majorVersion > rhs.majorVersion {
        return false
    }

    if lhs.minorVersion < rhs.minorVersion {
        return true
    } else if lhs.minorVersion > rhs.minorVersion {
        return false
    }

    if lhs.patchVersion < rhs.patchVersion {
        return true
    } else if lhs.patchVersion > rhs.patchVersion {
        return false
    }

    return false
}

// MARK: - Globals

internal var kDidCheckSDKVersion = false

internal func checkSDKVersionIfNeeded() {
    if kDidCheckSDKVersion {
        return
    }

    guard let frameworkVersionNumber = NSBundle.imglyKitBundle.infoDictionary?["CFBundleShortVersionString"] as? String, frameworkVersion = SDKVersion(string: frameworkVersionNumber) else {
        return
    }

    let appIdentifier = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
    if let appIdentifier = appIdentifier, url = NSURL(string: "https://www.photoeditorsdk.com/version.json?sdk=ios&app=\(appIdentifier)") {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
            if let data = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]

                    if let json = json, versionString = json["version"] as? String, remoteVersion = SDKVersion(string: versionString) {
                        if frameworkVersion < remoteVersion {
                            print("Your version of the img.ly SDK is outdated. You are using version \(frameworkVersion), the latest available version is \(remoteVersion). Please consider updating.")
                        }
                    }
                } catch {

                }
            }
        }

        task.resume()
        kDidCheckSDKVersion = true
    }
}
