//
//  Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 10/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import HandlerSDK

extension HRError {
    func show(){
        ErrorPopupQueue.sharedInstance.enqueueError(self)
    }
}
