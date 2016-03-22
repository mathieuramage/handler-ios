//
//  NSDate+Compare.swift
//  Handler
//
//  Created by Ryniere S Silva on 21/03/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation

extension NSDate {
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        
        var isGreater = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {

        var isLess = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {

        var isEqualTo = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        return isEqualTo
    }
}