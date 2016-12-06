//
//  CurrentStatusManager.swift
//  Handler
//
//  Created by Christian Praiss on 19/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Bond

enum StatusManagerStatus: String {
	case Idle = "Idle"
	case Uploading = "Uploading"
	case Sending = "Sending"
	case Error = "Error"
	case Offline = "Offline"
}

class CurrentStatusManager: NSObject, MailboxCountObserver {
	static let sharedInstance = CurrentStatusManager()
	
	var currentStatus = Observable("")
	var currentStatusSubtitle = Observable("")
	var currentState: Observable<StatusManagerStatus> = Observable(StatusManagerStatus.Idle)
	var currentUploadProgress: Observable<Float> = Observable(Float(0.0))

	private var unreadCount = 0
	
	override init() {
		super.init()
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(.Unread, observer: self)
		NotificationCenter.default.addObserver(self, selector: #selector(CurrentStatusManager.handleDidStartLoadingMessages), name:Notification.Name(MessageLoadingStatusNotification.loading.rawValue), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(CurrentStatusManager.handleDidFinishLoadingMessages), name:Notification.Name(MessageLoadingStatusNotification.finished.rawValue), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func mailboxCountDidChange(_ mailboxType: MailboxType, newCount: Int) {
		if mailboxType == .Unread && currentState.value == .Idle {
			unreadCount = newCount

			changeStatus("Updated Just Now", unreadCount: unreadCount)
		}
	}

	func handleDidStartLoadingMessages(_ notitication: NSNotification) {
		changeStatus("Checking for Mail...", unreadCount: nil)
	}

	func handleDidFinishLoadingMessages(_ notitication: NSNotification) {
		changeStatus("Updated Just Now", unreadCount: unreadCount)
	}

	func changeStatus(_ status: String, unreadCount: Int?) {
		if let unreadCount = unreadCount {
			let subtitle = unreadCount > 0 ? "\(unreadCount) Unread" : "No new emails. Your move"
			currentStatusSubtitle.next(subtitle)
		} else {
			currentStatusSubtitle.next("")
		}

		currentStatus.next(status)
	}
}
