//
//  WhiteBorderImageView.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

@IBDesignable
class WhiteBorderImageView: UIImageView {
	
	@IBInspectable var borderWidth: CGFloat = 3.0

	override func prepareForInterfaceBuilder() {
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = borderWidth
		clipsToBounds = true
	}
	
	func commonInit() {
		layer.borderColor = UIColor.white.cgColor
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

@IBDesignable
class WhiteBorderButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            commonInit()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            commonInit()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        commonInit()
    }
    
    func commonInit() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = bounds.size.height / 2
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = bounds.size.height / 2
        }
    }
}

