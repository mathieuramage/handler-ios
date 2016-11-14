//
//  CALayer+Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
	class func gradientLayerForBounds(_ bounds: CGRect) -> CAGradientLayer {
		let layer = CAGradientLayer()
		layer.frame = bounds
		layer.colors = UIColor.hrGradientColors()
		return layer
	}
}
