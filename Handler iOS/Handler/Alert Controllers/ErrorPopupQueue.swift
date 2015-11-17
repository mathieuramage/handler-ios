//
//  ErrorPopupQueue.swift
//  Handler
//
//  Created by Christian Praiss on 17/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

class ErrorPopupQueue: NSObject {
    private var errors: [ErrorPopupViewController] = [ErrorPopupViewController]()
    private var currentError: ErrorPopupViewController? {
        didSet {
            currentError?.show()
        }
    }
    static let sharedInstance = ErrorPopupQueue()
    
    func enqueueError(error: ErrorPopupViewController){
        errors.append(error)
        if let currentError = currentError {
            if let index = errors.indexOf(currentError) {
                if errors.count >= index + 1 {
                    let nextError = errors[index+1]
                    currentError.dismissalCallback = {
                        self.currentError = nextError
                    }
                }else{
                    error.dismissalCallback = {
                        self.currentError = nil
                    }
                }
            }
        }else{
            currentError = error
        }
    }
}
