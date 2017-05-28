//
//  MailboxActionHandler.swift
//  Handler
//
//  Created by Marco Antonio Nascimento on 22.05.17.
//  Copyright © 2017 Handler, Inc. All rights reserved.
//

import UIKit

class InboxActionHandler: MessageTableViewCellActions {
	
	let EmailActionEvents = AppEvents.EmailActions.self
	
	// MARK: Conversation Actions
	func leftButtonTriggered(_ index: Int, data conversation: Conversation, callback: (() -> Void)?) {
		
		switch index {
		case 0:
			if conversation.hasUnreadMessages {
				ConversationManager.markConversationAsRead(conversation)
			} else {
				ConversationManager.markConversationAsUnread(conversation)
			}
			break;
		default:
			break
		}
		
		defer{
			if let cb = callback {
				cb()
			}
		}
		
		// TODO: Implement actions
	}
	
	func rightButtonTriggered(_ index: Int, data conversation: Conversation, callback: (() -> Void)?) {
		
		switch index {
		case 0:
			if conversation.hasFlaggedMessages {
				ConversationManager.unflagConversation(conversation: conversation)
			} else {
				ConversationManager.flagConversation(conversation: conversation)
			}
			break
		case 1:
			ConversationManager.archiveConversation(conversation: conversation)
			break
		default:
			break
		}
		
		defer{
			if let cb = callback {
				cb()
			}
		}
	}
	
	// MARK: Actions
	func leftButtonTriggered(_ index: Int, data message: Message, callback: (() -> Void)?) {
		
		switch index {
		case 0:
			if !message.read {
				MessageManager.markMessageRead(message: message)
				AppAnalytics.fireContentViewEvent(contentId: EmailActionEvents.markRead, event: EmailActionEvents)
			} else {
				MessageManager.markMessageUnread(message: message)
				AppAnalytics.fireContentViewEvent(contentId: EmailActionEvents.markUnread, event: EmailActionEvents)
			}
			break;
		default:
			break
		}
		
		defer{
			if let cb = callback {
				cb()
			}
		}
		
		// TODO: Implement actions
	}
	
	func rightButtonTriggered(_ index: Int, data message: Message, callback: (() -> Void)?) {
		
		switch index {
		case 0:
			if message.starred {
				AppAnalytics.fireContentViewEvent(contentId: EmailActionEvents.unflagged, event: EmailActionEvents)
			} else {
				AppAnalytics.fireContentViewEvent(contentId: EmailActionEvents.flagged, event: EmailActionEvents)
			}
			break
		case 1:
			if message.archived {
				AppAnalytics.fireContentViewEvent(contentId: EmailActionEvents.unarchived, event: EmailActionEvents)
			} else {
				AppAnalytics.fireContentViewEvent(contentId: EmailActionEvents.archived, event: EmailActionEvents)
			}
			break
		default:
			break
		}
		
		defer{
			if let cb = callback {
				cb()
			}
		}
	}
	
	// MARK: Data Source
	
	func leftButtonsForData(data message: Message) -> [AnyObject] {
		let array = NSMutableArray()
		let readIcon = UIImage(named: "icon_read")?.imageResize(sizeChange: CGSize(width: 25, height: 23))
		let unreadIcon = UIImage(named: "icon_unread")?.imageResize(sizeChange: CGSize(width: 25, height: 17))
		
		if !message.read {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: readIcon)
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: unreadIcon)
		}
		return array as [AnyObject]
	}
	
	func rightButtonsForData(data message: Message) -> [AnyObject] {
		let array = NSMutableArray()
		let flagIcon = UIImage(named: "icon_flag")?.imageResize(sizeChange: CGSize(width: 25, height: 34))
		let unflagIcon = UIImage(named: "icon_unflag")?.imageResize(sizeChange: CGSize(width: 25, height: 44))
		let archiveIcon = UIImage(named: "icon_archive")?.imageResize(sizeChange: CGSize(width: 25, height: 20))
		
		if message.starred == true {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: unflagIcon)
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: flagIcon)
		}
		
		array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: archiveIcon)
		return array as [AnyObject]
	}
}
