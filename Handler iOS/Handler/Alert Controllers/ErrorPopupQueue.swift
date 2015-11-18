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
    private var errors: [HRError] = [HRError]()
    var currentError: ErrorPopupViewController? {
        didSet {
            currentError?.show()
        }
    }
    static let sharedInstance = ErrorPopupQueue()
    
    func enqueueError(error: HRError){
        errors.append(error)
        if let _ = currentError {
            
        }else{
            let errorPopup = ErrorPopupViewController()
            errorPopup.error = error
            currentError = errorPopup
        }
    }
    
    func nextError()->HRError?{
        if let currentError = currentError {
            if let index = errors.indexOf(currentError.error!) {
                if errors.count > index + 1 {
                    return errors[index+1]
                }else{
                    return nil
                }
            }
        }
        return nil
    }
}
