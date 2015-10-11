//
//  ErrorHandler.swift
//  Handler
//
//  Created by Christian Praiss on 11/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

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
