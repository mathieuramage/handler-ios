//
//  UIButton+ImageFitting.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

@IBDesignable
extension UIButton {
	open override func awakeFromNib() {
		super.awakeFromNib()
		self.imageView?.contentMode = .scaleAspectFit
	}
}

