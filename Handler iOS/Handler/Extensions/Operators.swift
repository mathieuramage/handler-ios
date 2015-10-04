//
//  Operators.swift
//  Handler
//
//  Created by Christian Praiss on 04/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation

prefix operator --> {}

prefix func --> (block:()->()){
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
        block()
    }
}