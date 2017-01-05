//
//  InboxActionHandler.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Crashlytics
import Intercom

class InboxActionHandler: MessageTableViewCellActions {
	
	let EmailActionEvents = Config.AppEvents.EmailActions.self

	// MARK: Actions

	func leftButtonTriggered(_ index: Int, data message: ManagedMessage, callback: (() -> Void)?) {

		switch index {
		case 0:
			if message.isUnread {
				message.conversation?.markAsRead()
				Intercom.logEvent(withName: EmailActionEvents.markRead)
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.markRead, customAttributes: nil)
			} else {
				message.conversation?.markAsUnread(message)
				Intercom.logEvent(withName: EmailActionEvents.markUnread)
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
				Intercom.logEvent(withName: EmailActionEvents.unflagged)
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.unflagged, customAttributes: nil)
			} else {
				message.flag()
				Intercom.logEvent(withName: EmailActionEvents.flagged)
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.flagged, customAttributes: nil)
			}
			break
		case 1:
			if message.isArchived {
				message.conversation?.unarchive()
				Intercom.logEvent(withName: EmailActionEvents.unarchived)
				Answers.logContentView(withName: EmailActionEvents.contentName, contentType: EmailActionEvents.contentType, contentId: EmailActionEvents.unarchived, customAttributes: nil)
			} else {
				message.conversation?.archive()
				Intercom.logEvent(withName: EmailActionEvents.archived)
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
