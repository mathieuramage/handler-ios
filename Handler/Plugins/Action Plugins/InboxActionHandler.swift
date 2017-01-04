//
//  InboxActionHandler.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Crashlytics

class InboxActionHandler: MessageTableViewCellActions {
	
	let EmailActionEvents = Config.AppEvents.EmailActions.self

	// MARK: Actions

	func leftButtonTriggered(_ index: Int, data message: ManagedMessage, callback: (() -> Void)?) {

		switch index {
		case 0:
			if message.isUnread {
				message.conversation?.markAsRead()
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.markRead, customAttributes: nil)
			} else {
				message.conversation?.markAsUnread(message)
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.markUnread, customAttributes: nil)
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

	func rightButtonTriggered(_ index: Int, data message: ManagedMessage, callback: (() -> Void)?) {

		switch index {
		case 0:
			if message.isFlagged {
				message.unflag()
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.unflagged, customAttributes: nil)
			} else {
				message.flag()
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.flagged, customAttributes: nil)
			}
			break
		case 1:
			if message.isArchived {
				message.conversation?.unarchive()
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.unarchived, customAttributes: nil)
			} else {
				message.conversation?.archive()
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.archived, customAttributes: nil)
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
		// TODO: Implement actions
	}

	// MARK: Data Source

	func leftButtonsForData(data message: ManagedMessage) -> [AnyObject] {
		let array = NSMutableArray()
		if message.isUnread {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_read"))
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_unread"))
		}
		return array as [AnyObject]
	}

	func rightButtonsForData(data message: ManagedMessage) -> [AnyObject] {
		let array = NSMutableArray()
		if message.isFlagged {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_unflag"))
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_flag"))
		}

		if message.isArchived {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_unarchive"))
		} else {
			array.sw_addUtilityButton(with: UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_archive"))
		}
		return array as [AnyObject]
	}
}
