//
//  UIImage+HanderImages.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import UIKit

let ghostImageNames = ["ghost_black", "ghost_blue", "ghost_green", "ghost_grey", "ghost_purple", "ghost_yellow", "ghost_red"]

extension UIImage {
	class func randomGhostImage() -> UIImage {
		return UIImage(named: ghostImageNames.randomItem())!
	}
}