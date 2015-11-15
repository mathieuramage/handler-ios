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
	
	var _interactionController: UIDocumentInteractionController?
	var interactionController: UIDocumentInteractionController? {
		get {
			if let cont = _interactionController {
				return cont
			}else{
				if let url = self.localFileURL {
					if NSFileManager.defaultManager().fileExistsAtPath(url){
						_interactionController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: url))
						_interactionController?.name = self.filename ?? ""
						return _interactionController
					}else{
						return nil
					}
				}else{
					return nil
				}
			}
		}
		}
	
	convenience init(localFile: NSURL, filename: String){
		self.init(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "filename", value: filename))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "localFileURL", value: localFile.path))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "content_type", value: UTI(filenameExtension: localFile.pathExtension ?? "").MIMEType))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "upload_complete", value: false))
        DatabaseChangesCache.sharedInstance.executeChangesForObjectID(self.objectID)
	}
	
	required convenience init(hrType: HRType, managedObjectContext: NSManagedObjectContext) {
		self.init(managedObjectContext: managedObjectContext)
		
		updateFromHRType(hrType)
	}
	
	func updateFromHRType(attachment: HRType) {
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "id", value: attachment.id))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "content_type", value: attachment.content_type))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "url", value: attachment.url))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "filename", value: attachment.filename))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "size", value: attachment.size))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "upload_complete", value: attachment.uploadComplete))
        DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "upload_url", value: attachment.upload_url))
        DatabaseChangesCache.sharedInstance.executeChangesForObjectID(self.objectID)

		
		guard let fl = self.localFileURL where fl == "" else{
			guard let docsDirString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).first else {
				return
			}
			if let filetype = NSURL(string: attachment.filename)?.pathExtension {
                DatabaseChangesCache.sharedInstance.addChange(DatabaseChange(object: self, property: "localFileURL", value: docsDirString.stringByAppendingString("/"+NSUUID().UUIDString.stringByAppendingString("." + filetype))))
                DatabaseChangesCache.sharedInstance.executeChangesForObjectID(self.objectID)
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
			
			if let data = NSData(contentsOfFile: search){
				return data
			} else if (self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) as! Attachment).involved_download == nil {
				// Data not yet loaded, start download
				print("starting downlaod for \(self.filename) to \(self.localFileURL)")
				let _ = HRDownloadAction(attachment: self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) as! Attachment)
			}
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
