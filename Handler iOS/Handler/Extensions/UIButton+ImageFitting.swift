//
//  UIButton+ImageFitting.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

@IBDesignable
extension UIButton {
	public override func awakeFromNib() {
		super.awakeFromNib()
		self.imageView?.contentMode = .ScaleAspectFit
	}
}

