//
//  Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 10/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import HandlerSDK

extension HRError {
    func show(){
        ErrorPopupQueue.sharedInstance.enqueueError(self)
    }
}
