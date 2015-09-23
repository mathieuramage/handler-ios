//
//  UIColor+HandlerColors.swift
//  Handler
//
//  Created by Christian Praiss on 23/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	class func hrBlueColor() -> UIColor {
		return UIColor(red: 85/255, green: 171/255, blue: 237/255, alpha: 1)
	}
	
	class func hrDarkBlueColor() -> UIColor {
		return UIColor(red: 39/255, green: 127/255, blue: 197/255, alpha: 1)
	}
	
	class func hrLightGrayColor() -> UIColor {
		return UIColor(red: 203/255, green: 213/255, blue: 221/255, alpha: 1)
	}
	
	class func hrOrangeColor() -> UIColor {
		return UIColor(red: 245/255, green: 149/255, blue: 17/255, alpha: 1)
	}
	
	class func hrNavigationGradientLight() -> UIColor {
		return UIColor(red: 85/255, green: 171/255, blue: 237/255, alpha: 1)
	}
	
	class func hrNavigationGradientDark() -> UIColor {
		return UIColor(red: 25/255, green: 203/255, blue: 217/255, alpha: 1)
	}
	
	class func hrGradientColors() -> [AnyObject] {
		return [hrNavigationGradientDark().CGColor, hrNavigationGradientLight().CGColor]
	}
}