//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import Foundation

#if os(iOS)
    import UIKit
    public typealias Color = UIColor
    public typealias Font = UIFont
    public typealias Image = UIImage
#else
    import Cocoa
    public typealias Color = NSColor
    public typealias Font = NSFont
    public typealias Image = NSImage
#endif
