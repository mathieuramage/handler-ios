//
//  UploadManager.swift
//  Handler
//
//  Created by Christian Praiss on 04/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import HandleriOSSDK

// OTTODO: Reimplement this whole class as needed
class UploadManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
	
//	var currentUploadTask: NSURLSessionUploadTask?
//	var currentCallback: ((success: Bool, error: HRError?)->Void)
//	var currentProgressHandler: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)->Void)?
//	
//	init(progressHandler: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)->Void)? = nil, callback: ((success: Bool, error: HRError?)->Void)) throws {
//		uploadAction = action
//		currentCallback = callback
//		currentProgressHandler = progressHandler
//		super.init()
//		
//		guard let attachment = uploadAction.attachment, let file = attachment.getData() else {
//			throw NSError(domain: "No attachment found", code: 404, userInfo: nil)
//		}
//		
//		if let uploadURLPath = attachment.upload_url, let uploadURL = NSURL(string: uploadURLPath), let uploadable = attachment.isUploadable where uploadable {
//			let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.handler.backgroundUpload.\(attachment.filename)")
//			let session = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
//			
//			let uploadRequest = NSMutableURLRequest(URL: uploadURL)
//			uploadRequest.setValue(attachment.getMime(), forHTTPHeaderField: "Content-Type")
//			uploadRequest.setValue("\(file.length)", forHTTPHeaderField: "Content-Length")
//			uploadRequest.setValue("public-read", forHTTPHeaderField: "x-amz-acl")
//			uploadRequest.HTTPMethod = "PUT"
//			uploadRequest.HTTPBody = file
//			
//			currentUploadTask = session.uploadTaskWithStreamedRequest(uploadRequest)
//			currentUploadTask?.resume()
//		} else {
//			currentCallback(success: false, error: HRError(title: "upload_cancelled", status: 999, detail: "The file upload was cancelled", displayMessage: "The application cannot perform this upload because the file url is either not correct or the file was already uploaded"))
//		}
//	}
//	
//	// MARK: URLSession Delegate
//	
//	func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
//		if let attachment = uploadAction.attachment {
//			if session.configuration.identifier == "com.handler.backgroundUpload.\(attachment.localFileURL)" {
//				AppDelegate.sharedInstance().backgroundSessionCompletionHandler?()
//			}
//		}
//	}
//	
//	func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//		let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
//		self.uploadAction.progress = NSNumber(double: progress)
//		DatabaseManager.sharedInstance.backgroundContext.saveRecursively()
//		currentProgressHandler?(bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
//		
//		print("\(totalBytesSent)/\(totalBytesExpectedToSend)")
//	}
//	
//	func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
//		if let error = error {
//			currentCallback(success: false, error: HRError(errorType: error))
//		} else {
//			currentCallback(success: false, error: HRError(title: "invalid_urlsession", status: 999, detail: "URLSession became invalid", displayMessage: "The upload of a file couldn't be completed"))
//		}
//	}
//	
//	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
//		if let error = error {
//			currentCallback(success: false, error: HRError(errorType: error))
//		} else {
//			if let hrType = self.uploadAction.attachment?.toHRType() {
//				HandlerAPI.markAttachmentAsCompleted(hrType, callback: { (attachment, error) -> Void in
//					guard let attachment = attachment else {
//						self.currentCallback(success: false, error: error)
//						return
//					}
//					self.uploadAction.attachment?.updateFromHRType(attachment)
//					self.currentCallback(success: true, error: nil)
//				})
//			}
//			
//		}
//	}
}
