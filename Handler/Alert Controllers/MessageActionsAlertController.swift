//
//  MessageActionsAlertController.swift
//  Handler
//
//  Created by Christian Praiss on 30/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class MessageActionsAlertController: UIAlertController {

	convenience init(message: LegacyMessage, vc: UIViewController){
		self.init()

		addAction(UIAlertAction(title: "Reply", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
			let replyNC = Storyboards.Compose.instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController
			let replyVC = replyNC.viewControllers.first as! MessageComposeTableViewController
			replyVC.messageToReplyTo = message
			vc.presentViewController(replyNC, animated: true, completion: nil)
		}))

		addAction(UIAlertAction(title: "Forward", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
			let replyNC = Storyboards.Compose.instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController
			let replyVC = replyNC.viewControllers.first as! MessageComposeTableViewController
			replyVC.messageToForward = message
			vc.presentViewController(replyNC, animated: true, completion: nil)
		}))
		addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
	}
	
}
