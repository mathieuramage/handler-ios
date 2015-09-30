//
//  SendInvitationViewController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class SendInvitationViewController: UIViewController, UIViewControllerShow {
	
	var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		UINib(nibName: nibNameOrNil!, bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func dismiss(){
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.window?.alpha = 0
			}) { (success) -> Void in
				self.window = nil
		}
	}
}
