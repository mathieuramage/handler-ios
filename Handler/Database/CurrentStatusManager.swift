//
//  CurrentStatusManager.swift
//  Handler
//
//  Created by Christian Praiss on 19/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Bond
import CoreData

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
	
	override init(){
		super.init()
		MailboxObserversManager.sharedInstance.addCountObserverForMailboxType(.Unread, observer: self)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "actionProgressChanged", name: ActionProgressDidChangeNotification, object: nil)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	func mailboxCountDidChange(mailboxType: MailboxType, newCount: Int) {
		if mailboxType == MailboxType.Unread && currentState.value == .Idle {
			if newCount != 0 {
				let emailsText = newCount == 1 ? "email" : "emails"
				currentStatus.next("\(newCount) unread " + emailsText)
				currentStatusSubtitle.next("Updated just now")
			}else{
				currentStatus.next("No new emails")
				currentStatusSubtitle.next("Updated just now")
			}
		}
	}
	
	
}
