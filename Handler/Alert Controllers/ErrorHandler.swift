//
//  ErrorHandler.swift
//  Handler
//
//  Created by Christian Praiss on 11/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import HandleriOSSDK

class ErrorHandler: NSObject {
    class func performErrorActions(error: HRError){
        let notification = CWStatusBarNotification()
        if error.displayMessage == "" {
            notification.displayNotificationWithMessage(error.description, forDuration: 3)
        }else{
            notification.displayNotificationWithMessage(error.displayMessage, forDuration: 3)
        }
    }
}
