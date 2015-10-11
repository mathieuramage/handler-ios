//
//  UploadManager.swift
//  Handler
//
//  Created by Christian Praiss on 04/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

class UploadManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
	
    var currentUploadTask: NSURLSessionUploadTask?
    var currentCallback: ((success: Bool, error: HRError?)->Void)?
    var currentProgressHandler: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)->Void)?
    var currentAttachment: Attachment?

    // MARK: URLSession generation
	
    func uploadFileToAttachment(file: NSData, attachment: Attachment, callback: ((success: Bool, error: HRError?)->Void)? = nil, progressHandler: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)->Void)? = nil){
        
        currentCallback = callback
        currentAttachment = attachment
        currentProgressHandler = progressHandler
        
        if let uploadURLPath = attachment.upload_url, let uploadURL = NSURL(string: uploadURLPath), let uploadable = attachment.isUploadable where uploadable {
            let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.chrisspraiss.backgroundUpload.\(attachment.filename)")
            let session = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
            
            let uploadRequest = NSMutableURLRequest(URL: uploadURL)
            uploadRequest.setValue(attachment.getMime(), forHTTPHeaderField: "Content-Type")
            uploadRequest.setValue("\(file.length)", forHTTPHeaderField: "Content-Length")
            uploadRequest.setValue("public-read", forHTTPHeaderField: "x-amz-acl")
            uploadRequest.HTTPMethod = "PUT"
            uploadRequest.HTTPBody = file
            
            currentUploadTask = session.uploadTaskWithStreamedRequest(uploadRequest)
            currentUploadTask?.resume()
        }else{
            currentCallback?(success: false, error: HRError(title: "upload_cancelled", status: 999, detail: "The file upload was cancelled", displayMessage: "The application cannot perform this upload because the file url is either not correct or the file was already uploaded"))
        }
	}
    
    // MARK: URLSession Delegate
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
		if let attachment = currentAttachment {
			if session.configuration.identifier == "com.chrisspraiss.backgroundUpload.\(attachment.filename)" {
				AppDelegate.sharedInstance().backgroundSessionCompletionHandler?()
			}
		}
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        currentProgressHandler?(bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        if let error = error {
            currentCallback?(success: false, error: HRError(errorType: error))
        }else{
            currentCallback?(success: false, error: HRError(title: "invalid_urlsession", status: 999, detail: "URLSession became invalid", displayMessage: "The upload of a file couldn't be completed"))
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            currentCallback?(success: false, error: HRError(errorType: error))
        }else{
            currentCallback?(success: true, error: nil)
			if let localattachment = currentAttachment {
				HandlerAPI.markAttachmentAsCompleted(localattachment.toHRType(), callback: { (attachment, error) -> Void in
					guard let attachment = attachment else {
						var errorPopup = ErrorPopupViewController()
						errorPopup.error = error
						errorPopup.show()
						return
					}
					localattachment.updateFromHRType(attachment)
					localattachment.upload_complete = NSNumber(bool: true)
					
					if let shouldBeSent = localattachment.contained_in?.shouldBeSent where shouldBeSent.boolValue {
						for attachment in localattachment.contained_in?.attachments?.allObjects as! [Attachment] {
							if let uplaodComplete = attachment.upload_complete where !uplaodComplete.boolValue {
								return
							}
						}
						localattachment.contained_in?.persistToAPI()
					}
				})
			}
        }
    }
}
