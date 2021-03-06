//
//  ErrorPopupViewController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

class ErrorPopupViewController: UIViewController, UIViewControllerShow {
	
	var window: UIWindow?
	
	var error: HRError? {
		didSet {
			if let error = error {
				displayMessageLabel.text = error.displayMessage
				UIView.animateWithDuration(0.2, animations: { () -> Void in
					self.view.layoutIfNeeded()
				})
			}
		}
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		UINib(nibName: "ErrorPopupViewController", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	@IBOutlet weak var displayMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func dismissPressed(sender: AnyObject?) {
        if let next = ErrorPopupQueue.sharedInstance.nextError() {
            self.error = next
        }else{
            dismiss()
        }
	}
	
	func dismiss(){
        ErrorPopupQueue.sharedInstance.currentError = nil
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.window?.alpha = 0
			UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
			}) { (success) -> Void in
				self.window = nil
		}
	}
}
