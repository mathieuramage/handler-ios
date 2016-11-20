//
//  ConversationsBottomBarActionsHandler.swift
//  Handler
//
//  Created by Christian Praiß on 12/13/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class ConversationsBottomBarActionsHandler: NSObject, BottomBarActionPlugin {

	let vc: ConversationTableViewController

	init(vc: ConversationTableViewController){
		self.vc = vc
	}

	lazy var left: UIBarButtonItem = {
		let element = UIBarButtonItem(image: UIImage(named: "Left_toolbar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ConversationsBottomBarActionsHandler.action(_:)))
		if let _ = self.vc.previousConversation {
			element.tintColor = UIColor(rgba: HexCodes.lightBlue)
		} else {
			element.tintColor = UIColor(rgba: HexCodes.lighterGray)
		}
		return element
	}()
	lazy var right: UIBarButtonItem = {
		let element = UIBarButtonItem(image: UIImage(named: "Right_toolbar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ConversationsBottomBarActionsHandler.action(_:)))
		if let _ = self.vc.nextConversation {
			element.tintColor = UIColor(rgba: HexCodes.lightBlue)
		} else {
			element.tintColor = UIColor(rgba: HexCodes.lighterGray)
		}
		return element
	}()
	lazy var flag: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Flag_toolbar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ConversationsBottomBarActionsHandler.action(_:)))
	}()
	lazy var archive: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Archive_toolbar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ConversationsBottomBarActionsHandler.action(_:)))
	}()
	lazy var reply: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Reply_toolbar"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ConversationsBottomBarActionsHandler.action(_:)))
	}()
	let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

	func barButtonItemsForThread(_ thread: Thread? = nil) -> [UIBarButtonItem] {
		return [left, space, right, space, flag, space, archive, space, reply]
	}

	func action(_ item: UIBarButtonItem){
		if let message = vc.primaryMessage {
			switch item {
			case left:
//				if let next = vc.previousThread {
//					vc.thread = next
//					if let _ = vc.previousThread {
//						left.tintColor = UIColor(rgba: HexCodes.lightBlue)
//					} else {
//						left.tintColor = UIColor(rgba: HexCodes.lighterGray)
//					}
//					if let _ = vc.nextThread {
//						right.tintColor = UIColor(rgba: HexCodes.lightBlue)
//					} else {
//						right.tintColor = UIColor(rgba: HexCodes.lighterGray)
//					}
//				}
				break;
			case right:
//				if let next = vc.nextThread {
//					vc.thread = next
//					if let _ = vc.previousThread {
//						left.tintColor = UIColor(rgba: HexCodes.lightBlue)
//					} else {
//						left.tintColor = UIColor(rgba: HexCodes.lighterGray)
//					}
//					if let _ = vc.nextThread {
//						right.tintColor = UIColor(rgba: HexCodes.lightBlue)
//					} else {
//						right.tintColor = UIColor(rgba: HexCodes.lighterGray)
//					}
//				}
				break;
			case flag:
				let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

				let title : String
				if message.starred {
					title = "Unstar"
				} else {
					title = "Star"
				}
				cont.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) -> Void in
					MessageOperations.setMessageStarred(message: message, starred: !message.starred, callback: nil)
//					self.vc.reloadCellForMessage(message)
					// TODO: Add success message
				}))
				cont.addAction(UIAlertAction(title: "Mark as unread", style: UIAlertActionStyle.default, handler: { (action) -> Void in
					if !message.read {
						MessageOperations.setMessageAsRead(message: message, read: true, callback: { (success) in
						})
					} else {
//						message.thread?.markAsUnread(message)
					}
					self.vc.tableView.reloadData() //All newer messages will be reloaded
					// TODO: Add success message
				}))
				cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
				self.vc.present(cont, animated: true, completion: nil)
				break;
			case archive:
				let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
				cont.addAction(UIAlertAction(title: message.archived ? "Move to Inbox" : "Archive", style: UIAlertActionStyle.default, handler: { (action) -> Void in
//					message.isArchived ? message.thread?.unarchive() : message.thread?.archive()
					// TODO: Add success message
				}))
				cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
				self.vc.present(cont, animated: true, completion: nil)
				break;
			case reply:
				let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
				cont.addAction(UIAlertAction(title: "Reply", style: UIAlertActionStyle.default, handler: { (action) -> Void in
					let replyNC = Storyboards.Compose.instantiateViewController(withIdentifier: "MessageComposeNavigationController") as! GradientNavigationController
					let replyWrapper = replyNC.viewControllers.first as! MessageComposerWrapperViewController
//					replyWrapper.messageToReplyTo = message
					replyWrapper.title = "New Reply"
					self.vc.present(replyNC, animated: true, completion: nil)
				}))
				cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
				vc.present(cont, animated: true, completion: nil)
				break;
			default:
				break;
			}
		}
	}
}
