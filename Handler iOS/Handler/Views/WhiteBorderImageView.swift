//
//  WhiteBorderImageView.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class WhiteBorderImageView: UIImageView {
	
	@IBInspectable var borderWidth: CGFloat = 2.0
	
	override func prepareForInterfaceBuilder() {
		layer.cornerRadius = 3
		layer.borderColor = UIColor.whiteColor().CGColor
		layer.borderWidth = borderWidth
		clipsToBounds = true
	}
	
	func commonInit(){
		layer.cornerRadius = 3
		layer.borderColor = UIColor.whiteColor().CGColor
		layer.borderWidth = borderWidth
		clipsToBounds = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override init(image: UIImage?) {
		super.init(image: image)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
}
