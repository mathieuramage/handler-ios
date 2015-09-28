//
//  ErrorPopupView.swift
//  Handler
//
//  Created by Christian Praiss on 28/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class ErrorPopupView: UIView {

	class func fromNib()->ErrorPopupView {
		if let view = UINib(nibName: "ErrorPopupView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? ErrorPopupView {
			return view
		}else {
			return ErrorPopupView()
		}
	}

}
