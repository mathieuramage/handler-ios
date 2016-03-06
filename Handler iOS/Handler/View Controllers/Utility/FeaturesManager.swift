//
//  FeaturesManager.swift
//  Handler
//
//  Created by Christian Praiss on 14/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class FeaturesManager: NSObject {
    static var attachmentsActivated: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("attachmentsActivated")
        }
        set (new){
            NSUserDefaults.standardUserDefaults().setBool(new, forKey: "attachmentsActivated")
        }
    }
}
