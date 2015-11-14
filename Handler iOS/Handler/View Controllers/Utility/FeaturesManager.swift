//
//  FeaturesManager.swift
//  Handler
//
//  Created by Christian Praiss on 14/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class FeaturesManager: NSObject {
    static var attachmentsActivated: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("attachmentsActivated")
        }
    }
}
