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
        if let url = self.getLocalFileURL() {
            let interactionController = UIDocumentInteractionController(URL: url)
            return interactionController
        }else{
            return nil
        }
    }()
    
    convenience init(localFile: NSURL){
        self.init(managedObjectContext: MailDatabaseManager.sharedInstance.managedObjectContext)
        
        self.localFileURL = localFile.lastPathComponent
        if let filename = localFile.lastPathComponent {
            self.filename = filename
            self.content_type = UTI(filenameExtension: localFile.pathExtension ?? "").MIMEType
        }
        self.upload_complete = false
        
        let _ = try? managedObjectContext?.save()
    }
    
    func getUTI() -> String? {
        return interactionController?.UTI
    }
    
    func displayFileType() -> String? {
        return NSURL(string: self.filename ?? "")?.pathExtension ?? content_type
    }
    
    
    func getData() -> NSData? {
        if let search = getLocalFileURL() {
            return NSData(contentsOfURL: search)
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
        
    func getLocalFileURL()->NSURL?{
        guard let docsDirString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).first else {
            print("caches directory not found")
            return nil
        }
        
        return NSURL(fileURLWithPath: docsDirString).URLByAppendingPathComponent(filename ?? "")
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
    }
    
    // MARK: Validation
    
    var isUploadable: Bool! {
        if let id = id where id != "", let fileType = content_type where fileType != "", let uploadURL = upload_url where uploadURL != "", let complete = upload_complete where !complete.boolValue {
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
