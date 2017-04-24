//
//  Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 10/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation

//extension HRError {
//    func show() {
//        ErrorPopupQueue.sharedInstance.enqueueError(self)
//    }
//}


extension Double {
	// Rounds the double to decimal places value
	mutating func roundToPlaces(_ places : Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self.rounded() * divisor) / divisor
	}
}
