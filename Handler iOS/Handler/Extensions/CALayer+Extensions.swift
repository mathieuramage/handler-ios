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
		layer.colors = UIColor.hrGradientColors()
		return layer
	}
}