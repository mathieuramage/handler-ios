//
//  CurrentStatusManager.swift
//  Handler
//
//  Created by Christian Praiss on 19/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
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
	
	func actionProgressChanged(){
		let downloadFR = NSFetchRequest(entityName: "HRDownloadAction")
		let predicate = NSPredicate(format: "running == YES AND completed == NO AND hadError == NO")
		downloadFR.predicate = predicate
		downloadFR.sortDescriptors = [NSSortDescriptor(key: "running", ascending: true)]
		let uploadFR = NSFetchRequest(entityName: "HRUploadAction")
		uploadFR.predicate = predicate
		uploadFR.sortDescriptors = [NSSortDescriptor(key: "running", ascending: true)]
		do {
			var totalProgress = Float(0.0)
			if let activeDownloads = try MailDatabaseManager.sharedInstance.backgroundContext.executeFetchRequest(downloadFR) as? [HRDownloadAction], let activeUploads = try MailDatabaseManager.sharedInstance.backgroundContext.executeFetchRequest(uploadFR) as? [HRUploadAction] {
				
				for download in activeDownloads {
					totalProgress += download.progress?.floatValue ?? 0.0
				}
				
				for upload in activeUploads {
					totalProgress += upload.progress?.floatValue ?? 0.0
				}
				
				currentUploadProgress.next(totalProgress / Float(activeDownloads.count+activeUploads.count))
				
			}else{
				throw NSError(domain: "failed to fetch actions", code: 500, userInfo: nil)
			}
		} catch {
			print(error)
		}
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
