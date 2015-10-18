//
//  Attachment.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK
import MobileCoreServices

final class Attachment: NSManagedObject, CoreDataConvertible {
	
	// MARK: HRType Conversion
	
	typealias HRType = HRAttachment
	
	lazy var interactionController: UIDocumentInteractionController? = {
		if let url = self.localFileURL {
			let interactionController = UIDocumentInteractionController(URL: NSURL(string: url)!)
			return interactionController
		}else{
			return nil
		}
		}()
	
    convenience init(localFile: NSURL, filename: String){
		self.init(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
        self.filename = filename
		if let filename = localFile.lastPathComponent {
			self.localFileURL = filename
			self.content_type = UTI(filenameExtension: localFile.pathExtension ?? "").MIMEType
		}
		self.upload_complete = false
	}
	
	required convenience init(hrType: HRType, managedObjectContext: NSManagedObjectContext) {
		self.init(managedObjectContext: managedObjectContext)
		
		updateFromHRType(hrType)
	}
	
	func updateFromHRType(attachment: HRType) {
		self.id = attachment.id
		self.content_type = attachment.content_type
		self.url = attachment.url
        self.filename = attachment.filename
		self.size = attachment.size
		self.upload_complete = attachment.uploadComplete
		self.upload_url = attachment.upload_url
        
        guard let _ = self.localFileURL else{
            guard let docsDirString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).first else {
                return
            }
            if let filetype = NSURL(string: attachment.filename)?.pathExtension {
                self.localFileURL = docsDirString.stringByAppendingString(NSUUID().UUIDString.stringByAppendingString("." + filetype))
            }
            return
        }
	}
	
	
	func toHRType() -> HRAttachment {
		let hrAttachment = HRAttachment()
		hrAttachment.id = self.id ?? ""
		hrAttachment.content_type = self.content_type ?? ""
		hrAttachment.url = self.url ?? ""
		hrAttachment.filename = self.filename ?? ""
		hrAttachment.size = self.size?.integerValue ?? 0
		hrAttachment.uploadComplete = self.upload_complete?.boolValue ?? false
		return hrAttachment
	}
	
	// Mark: Utils / Getters
	
	func delete() {
		if let locURL = localFileURL {
			do {
				try NSFileManager().removeItemAtPath(locURL)
			} catch {
				print(error)
			}
		}
		self.managedObjectContext?.deleteObject(self)
	}
	
	func getMime() -> String {
		return UTI(getUTI() ?? "").MIMEType ?? ""
	}
	
	func getUTI() -> String? {
		return interactionController?.UTI
	}
	
	func displayFileType() -> String? {
		return NSURL(string: self.filename ?? "")?.pathExtension ?? content_type
	}
	
	
	func getData() -> NSData? {
		if let search = localFileURL {
			return NSData(contentsOfFile: search)
		}else{
			return nil
		}
	}
	
	func fileSize () -> Int64 {
		if let data = getData() {
			return Int64(data.length)
		}else{
			return 0
		}
	}
	
	func fileSizeDisplayString() -> String {
		return NSByteCountFormatter().stringFromByteCount(fileSize())
	}
	
	func getIcon() -> (UIImage, UIViewContentMode) {
		return (UIImage(named: "One_Image_Attatchment")!, UIViewContentMode.Center)
	}
	
	func previewImage() -> (UIImage, UIViewContentMode) {
		if let data = getData(), let image = UIImage(data: data) {
			return (image, UIViewContentMode.ScaleAspectFill)
		}else if let image = interactionController?.icons.first {
			return (image, UIViewContentMode.ScaleAspectFit)
		}
		
		return (UIImage(named: "One_Image_Attatchment")!, UIViewContentMode.Center)
	}
	
	// MARK: Validation
	
	var isUploadable: Bool! {
		if let id = id where id != "", let uploadURL = upload_url where uploadURL != "", let complete = upload_complete where !complete.boolValue && getMime() != "" {
			return true
		}
		return false
	}
	
	var isSavedLocally: Bool {
		if let localURL = localFileURL where NSFileManager().fileExistsAtPath(localURL) {
			return true
		}
		return false
	}
	
	var isComplete: Bool {
		if let id = id where id != "", let url = url where url != "", let filename = filename where filename != "", let size = size where size.intValue != 0 {
			return true
		}
		return false
	}
}
