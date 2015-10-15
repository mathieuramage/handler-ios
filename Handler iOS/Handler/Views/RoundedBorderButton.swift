//
//  RoundedBorderButton.swift
//  Handler
//
//  Created by Christian Praiss on 15/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedBorderButton: UIButton {

	override init(frame: CGRect) {
		super.init(frame: frame)
		config()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		config()
	}
	
	func config(){
		self.layer.borderColor = UIColor.whiteColor().CGColor
		self.layer.borderWidth = 1
		self.layer.cornerRadius = self.bounds.size.height / 2
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.bounds.size.height / 2
	}
	
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
