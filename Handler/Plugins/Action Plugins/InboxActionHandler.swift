//
//  InboxActionHandler.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class InboxActionHandler: MessageTableViewCellActions {

	// MARK: Actions

	// OTTODO: Implement?
	func leftButtonTriggered(index: Int, data message: ManagedMessage, callback: (() -> Void)?) {

		switch index {
		case 0:
//			message.isUnread ? message.thread?.markAsRead() : message.thread?.markAsUnread(message)
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

	// OTTODO: Implement
	func rightButtonTriggered(index: Int, data message: ManagedMessage, callback: (() -> Void)?) {

		switch index {
		case 0:
			message.isFlagged ? message.unflag() : message.flag()
			break
		case 1:
//			message.isArchived ? message.thread?.unarchive() : message.thread?.archive()
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
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_read"))
		} else {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "icon_unread"))
		}
		return array as [AnyObject]
	}

	func rightButtonsForData(data message: ManagedMessage) -> [AnyObject] {
		let array = NSMutableArray()
		if message.isFlagged {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_unflag"))
		} else {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.orange), icon: UIImage(named: "icon_flag"))
		}

		if message.isArchived {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_unarchive"))
		} else {
			array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "icon_archive"))
		}
		return array as [AnyObject]
	}
}
