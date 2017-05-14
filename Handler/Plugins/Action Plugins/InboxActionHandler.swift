//
//  InboxActionHandler.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class InboxActionHandler: MessageTableViewCellActions {
	
	let EmailActionEvents = AppEvents.EmailActions.self
	
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
		if !message.read {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_read"))
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_unread"))
		}
		return array as [AnyObject]
	}

	func rightButtonsForData(data message: Message) -> [AnyObject] {
		let array = NSMutableArray()
		if message.starred {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_unflag"))
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_flag"))
		}
		
		if message.archived {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_unarchive"))
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_archive"))
		}
		return array as [AnyObject]
	}
}
