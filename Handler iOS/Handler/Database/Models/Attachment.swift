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

final class Attachment: NSManagedObject, CoreDataConvertible {
    
    // MARK: HRType Conversion
    
    typealias HRType = HRAttachment
    
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
        if let localData = local_data where localData.length != 0 {
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
