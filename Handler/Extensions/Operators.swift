//
//  Operators.swift
//  Handler
//
//  Created by Christian Praiss on 04/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

prefix operator -->

prefix func --> (block:@escaping ()->()){
    DispatchQueue.main.async { () -> Void in
        block()
    }
}
