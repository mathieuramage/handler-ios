//
//  ErrorPopupViewController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ErrorPopupViewController: UIViewController, UIViewControllerShow {
	
	var window: UIWindow?
	
	var error: HandlerError? {
		didSet {
			if let error = error {
				displayMessageLabel.text = error.displayMessage
				UIView.animate(withDuration: 0.2, animations: { () -> Void in
					self.view.layoutIfNeeded()
				})
			}
		}
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		UINib(nibName: "ErrorPopupViewController", bundle: Bundle.main).instantiate(withOwner: self, options: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	@IBOutlet weak var displayMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func dismissPressed(_ sender: AnyObject?) {
        if let next = ErrorPopupQueue.sharedInstance.nextError() {
            self.error = next
        } else {
            dismiss()
        }
	}
	
	func dismiss() {
        ErrorPopupQueue.sharedInstance.currentError = nil
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			self.window?.alpha = 0
			UIApplication.shared.statusBarStyle = .lightContent
			}, completion: { (success) -> Void in
				self.window = nil
		}) 
	}
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
