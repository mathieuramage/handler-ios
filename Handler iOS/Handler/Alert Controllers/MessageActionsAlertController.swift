//
//  MessageActionsAlertController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MessageActionsAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	convenience init(message: Message, vc: UIViewController){
		self.init()
		
		addAction(UIAlertAction(title: "Reply", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
			let replyNC = (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController)
			let replyVC = replyNC.viewControllers.first as! MessageComposeTableViewController
			replyVC.messageToReplyTo = message
			vc.presentViewController(replyNC, animated: true, completion: nil)
		}))
		
		addAction(UIAlertAction(title: "Forward", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
			let replyNC = (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController)
			let replyVC = replyNC.viewControllers.first as! MessageComposeTableViewController
			replyVC.messageToForward = message
			vc.presentViewController(replyNC, animated: true, completion: nil)
		}))
		addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
	}

}
