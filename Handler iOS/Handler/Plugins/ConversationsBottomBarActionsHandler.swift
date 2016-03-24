//
//  ConversationsBottomBarActionsHandler.swift
//  Handler
//
//  Created by Christian Praiß on 12/13/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ConversationsBottomBarActionsHandler: NSObject, BottomBarActionPlugin {
	
	let vc: ThreadTableViewController
	
	init(vc: ThreadTableViewController){
		self.vc = vc
	}
	
	lazy var left: UIBarButtonItem = {
		let element = UIBarButtonItem(image: UIImage(named: "Left_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
		if let _ = self.vc.previousThread {
			element.tintColor = UIColor(rgba: HexCodes.lightBlue)
		}else{
			element.tintColor = UIColor(rgba: HexCodes.lighterGray)
		}
		return element
	}()
	lazy var right: UIBarButtonItem = {
		let element = UIBarButtonItem(image: UIImage(named: "Right_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
		if let _ = self.vc.nextThread {
			element.tintColor = UIColor(rgba: HexCodes.lightBlue)
		}else{
			element.tintColor = UIColor(rgba: HexCodes.lighterGray)
		}
		return element
	}()
	lazy var flag: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Flag_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	lazy var archive: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Archive_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	lazy var reply: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Reply_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
	
	func barButtonItemsForThread(thread: Thread? = nil) -> [UIBarButtonItem] {
		return [left, space, right, space, flag, space, archive, space, reply]
	}
	
	func action(item: UIBarButtonItem){
		if let message = vc.primaryMessage {
			switch item {
			case left:
				if let next = vc.previousThread {
					vc.thread = next
					if let _ = vc.previousThread {
						left.tintColor = UIColor(rgba: HexCodes.lightBlue)
					}else{
						left.tintColor = UIColor(rgba: HexCodes.lighterGray)
					}
					if let _ = vc.nextThread {
						right.tintColor = UIColor(rgba: HexCodes.lightBlue)
					}else{
						right.tintColor = UIColor(rgba: HexCodes.lighterGray)
					}
				}
				break;
			case right:
				if let next = vc.nextThread {
					vc.thread = next
					if let _ = vc.previousThread {
						left.tintColor = UIColor(rgba: HexCodes.lightBlue)
					}else{
						left.tintColor = UIColor(rgba: HexCodes.lighterGray)
					}
					if let _ = vc.nextThread {
						right.tintColor = UIColor(rgba: HexCodes.lightBlue)
					}else{
						right.tintColor = UIColor(rgba: HexCodes.lighterGray)
					}
				}
				break;
			case flag:
				let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
				cont.addAction(UIAlertAction(title: message.isFlagged ? "Unflag" : "Flag", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					message.isFlagged ? message.unflag() : message.flag()
					// TODO: Add success message
				}))
				cont.addAction(UIAlertAction(title: "Mark as unread", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					if message.isUnread {
						message.markAsRead()
					} else {
						message.thread?.markAsUnread(message)
					}
					// TODO: Add success message
				}))
				cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
				self.vc.presentViewController(cont, animated: true, completion: nil)
				break;
			case archive:
				let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
				cont.addAction(UIAlertAction(title: message.isArchived ? "Unarchive" : "Archive", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					message.isArchived ? message.thread?.unarchive() : message.thread?.archive()
					// TODO: Add success message
				}))
				cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
				self.vc.presentViewController(cont, animated: true, completion: nil)
				break;
			case reply:
				let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
				cont.addAction(UIAlertAction(title: "Reply", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					let replyNC = (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("MessageComposeNavigationController") as! GradientNavigationController)
					let replyWrapper = replyNC.viewControllers.first as! MessageComposerWrapperViewController
					replyWrapper.messageToReplyTo = message
					self.vc.presentViewController(replyNC, animated: true, completion: nil)
				}))
				cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
				vc.presentViewController(cont, animated: true, completion: nil)
				break;
			default:
				break;
			}
		}
	}
}
