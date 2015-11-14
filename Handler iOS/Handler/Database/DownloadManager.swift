//
//  DownloadManager.swift
//  Handler
//
//  Created by Christian Praiss on 18/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

let AttachmentDownloadDidFinishNotification = "AttachmentDownloadDidFinish"
let AttachmentDownloadDidErrorNotification = "AttachmentDownloadDidError"

class DownloadManager: NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
	var currentDownloadTask: NSURLSessionDownloadTask?
	var currentCallback: ((success: Bool, error: HRError?)->Void)
	var currentProgressHandler: ((bytesWritten: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)->Void)?
	var downloadAction: HRDownloadAction
	
	init(action: HRDownloadAction, progressHandler: ((bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)->Void)? = nil, callback: ((success: Bool, error: HRError?)->Void)) throws {
		downloadAction = action
		currentCallback = callback
		currentProgressHandler = progressHandler
		super.init()
		
		guard let attachment = downloadAction.attachment, let url = attachment.url else {
			throw NSError(domain: "No attachment url found", code: 404, userInfo: nil)
		}
		
		if let downloadURL = NSURL(string: url) {
			let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.handler.backgroundDownload.\(attachment.localFileURL)")
			let session = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
			
			let downloadRequest = NSMutableURLRequest(URL: downloadURL)
			currentDownloadTask = session.downloadTaskWithRequest(downloadRequest)
			currentDownloadTask?.resume()
		}else{
			currentCallback(success: false, error: HRError(title: "upload_cancelled", status: 999, detail: "The file upload was cancelled", displayMessage: "The application cannot perform this upload because the file url is either not correct or the file was already uploaded"))
		}
	}
	
	// MARK: URLSession Delegate
	
	func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
		if let attachment = downloadAction.attachment {
			if session.configuration.identifier == "com.handler.backgroundDownload.\(attachment.localFileURL)" {
				AppDelegate.sharedInstance().backgroundSessionCompletionHandler?()
			}
		}
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
		self.downloadAction.progress = NSNumber(double: progress)
		MailDatabaseManager.sharedInstance.saveBackgroundContext()
		NSNotificationCenter.defaultCenter().postNotificationName(ActionProgressDidChangeNotification, object: nil)
		self.currentProgressHandler?(bytesWritten: bytesWritten, totalBytesSent: totalBytesWritten, totalBytesExpectedToSend: totalBytesExpectedToWrite)
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
		if let locURLString = self.downloadAction.attachment?.localFileURL {
			if let data = NSData(contentsOfFile: location.path!) {
				data.writeToFile(locURLString, atomically: true)
				currentCallback(success: true, error: nil)
				NSNotificationCenter.defaultCenter().postNotificationName(AttachmentDownloadDidFinishNotification, object: nil, userInfo: ["id": self.downloadAction.attachment?.id ?? ""])
			}else{
				currentCallback(success: false, error: HRError(title: "failed_to_save", status: 999, detail: "couldn't open downloaded data", displayMessage: "The download of a file couldn't be completed"))
			}
		}else{
			NSNotificationCenter.defaultCenter().postNotificationName(AttachmentDownloadDidErrorNotification, object: nil, userInfo: ["id": self.downloadAction.attachment?.id ?? ""])
			currentCallback(success: false, error: HRError(title: "failed_to_save", status: 999, detail: "had no local url", displayMessage: "The download of a file couldn't be completed"))
		}
		
	}
	
	func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
		if let error = error {
			currentCallback(success: false, error: HRError(errorType: error))
		}else{
			currentCallback(success: false, error: HRError(title: "invalid_urlsession", status: 999, detail: "URLSession became invalid", displayMessage: "The upload of a file couldn't be completed"))
		}
		NSNotificationCenter.defaultCenter().postNotificationName(AttachmentDownloadDidErrorNotification, object: nil, userInfo: ["id": self.downloadAction.attachment?.id ?? ""])
	}
	
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		if let error = error {
			currentCallback(success: false, error: HRError(errorType: error))
			NSNotificationCenter.defaultCenter().postNotificationName(AttachmentDownloadDidErrorNotification, object: nil, userInfo: ["id": self.downloadAction.attachment?.id ?? ""])
		}
	}
	
}
