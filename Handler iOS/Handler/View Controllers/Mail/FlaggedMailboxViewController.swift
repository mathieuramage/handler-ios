//
//  FlaggedMailboxViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 20/3/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class FlaggedMailboxViewController: AbstractMailboxViewController {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		mailboxType = .Flagged
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "showThreadTableViewController" {
			let dc = segue.destinationViewController as! ThreadTableViewController
			dc.thread = self.messageForSegue?.thread
			
			var threads = [Thread]()
			for message in self.fetchedObjects {
				if let thread = message.thread {
					threads.append(thread)
				}
			}
			dc.allThreads = threads
			dc.primaryMessage = self.messageForSegue

		} else if segue.identifier == "showMessageComposeNavigationController" { //TODO : This part will work when we have a bottom bar. 
			let dc = (segue.destinationViewController as! UINavigationController).viewControllers.first as! MessageComposeTableViewController
			dc.draftMessage = self.messageForSegue
		}
	}
}
