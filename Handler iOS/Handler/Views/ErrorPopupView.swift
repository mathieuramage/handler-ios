//
//  ErrorPopupView.swift
//  Handler
//
//  Created by Christian Praiss on 28/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

class ErrorPopupView: UIView {
	
	var showWindow: UIWindow?

	@IBOutlet var errorDescriptionLabel: UILabel!
	
	var error: HRError? {
		didSet{
			errorDescriptionLabel.text = error?.displayMessage ?? ""
		}
	}
	
	class func fromNib()->ErrorPopupView {
		if let view = UINib(nibName: "ErrorPopupView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? ErrorPopupView {
			return view
		}else {
			return ErrorPopupView()
		}
	}

	class func showWithError(error: HRError){
		let view = fromNib()
		view.error = error
		view.show()
	}
}
