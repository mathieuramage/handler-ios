//
//  CALayer+Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
	class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
		let layer = CAGradientLayer()
		layer.frame = bounds
		layer.colors = [UIColor(red: 25/255, green: 203/255, blue: 217/255, alpha: 1).CGColor, UIColor(red: 85/255, green: 171/255, blue: 237/255, alpha: 1).CGColor]
		return layer
	}
}