//
//  Message+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


extension Message {
    
    var archived : Bool {
        return folderString == Folder.Archived.rawValue
    }
	
    convenience init(data : MessageData, context : NSManagedObjectContext) {
        self.init(context: context)
			setMessageData(data)
    }
	
    func setMessageData(_ data : MessageData) {
		identifier = data.identifier
		subject = data.subject
		content = data.content
		createdAt = data.createdAt?.NSDateValue
		updatedAt = data.updatedAt?.NSDateValue
		read = data.read
		folderString = data.folderString
    }
    
    // MARK: Labels
    
    func updateLabelsOnHRAPI(_ completion: ((_ success: Bool)->Void)? = nil){
        //		if let id = self.id {
        //			APICommunicator.sharedInstance.setLabelsToMessageWithID(id, setLabels: hrTypeLabels(), callback: { (labels, error) -> Void in
        //				guard let labels = labels else {
        //					if let error = error {
        //						ErrorHandler.performErrorActions(error)
        //					}
        //					completion?(success: false)
        //					return
        //				}
        //
        //				self.setLabelsFromHRTypes(labels)
        //				MailDatabaseManager.sharedInstance.saveBackgroundContext()
        //				completion?(success: true)
        //			})
        //		}
    }
    
    fileprivate func addLabelWithID(_ id: String, updateOnApi: Bool = true){
        //		if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
        //			if let label = Label.fromID(id) {
        //				if let myLabels = backgroundSelf.labels {
        //					let newSet = myLabels.setByAddingObject(label)
        //					backgroundSelf.labels = newSet
        //				}
        //
        //				if updateOnApi {
        //					backgroundSelf.updateLabelsOnHRAPI()
        //				}
        //				backgroundSelf.Conversation?.updateInbox()
        //				MailDatabaseManager.sharedInstance.saveBackgroundContext()
        //			}
        //		}
    }
    
    fileprivate func removeLabelWithID(_ id: String, updateOnApi: Bool = true){
        //		if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
        //			if let labelsArray = backgroundSelf.labels?.allObjects {
        //				for label in labelsArray {
        //					if label.id == id {
        //						if let myLabels = backgroundSelf.labels {
        //							let newSet = NSMutableSet(set: myLabels)
        //							newSet.removeObject(label)
        //							backgroundSelf.labels = NSSet(set: newSet)
        //						}
        //
        //						if updateOnApi {
        //							backgroundSelf.updateLabelsOnHRAPI()
        //						}
        //						backgroundSelf.Conversation?.updateInbox()
        //						MailDatabaseManager.sharedInstance.saveBackgroundContext()
        //						return
        //					}
        //				}
        //			}
        //		}
    }
    
    // MARK: Utility getters
    
    func recipientsWithoutSelf() -> NSSet? {
        if let recipients = self.recipients?.allObjects as? [User] {
            for recipient in recipients {
                if recipient.handle == AuthUtility.user?.handle {
                    let mutableSet = NSMutableSet(set: self.recipients!)
                    mutableSet.remove(recipient)
                    return NSSet(set: mutableSet)
                }
            }
        }
        
        return self.recipients
    }
    
    // MARK: State getter utilities
    
    
    var isInbox: Bool {
        get {
            let unread = false
            //			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
            //				if let labels = backgroundSelf.labels {
            //					for label in labels {
            //						if label.id == "INBOX" {
            //							unread = true
            //						}
            //					}
            //				}
            //			}
            return unread
        }
    }
    
    var isFlagged: Bool {
        get {
            //			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
            //
            //				if let labels = backgroundSelf.labels {
            //					for label in labels {
            //						if label.id == "IMPORTANT" {
            //							return true
            //						}
            //					}
            //				}
            //			}
            return false
        }
    }
    
    var isArchived: Bool {
        get {
            //			if let backgroundSelf = self.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
            //
            //				if let labels = backgroundSelf.labels {
            //					for label in labels {
            //						if label.id == "INBOX" {
            //							return false
            //						}
            //					}
            //				}
            //			}
            return true
        }
    }
    
    var isDraft: Bool {
        return folderString == SystemLabels.Drafts.rawValue
    }
    
    // TODO: Make it locale indepent
//    let replyPrefix = "Re:"
//    let forwardPrefix = "Fwd:"
    
    func hasReplyPrefix() -> Bool {
        //		guard let subject = self.subject else {
        //			return false
        //		}
        //
        //		return subject.lowercaseString.hasPrefix(replyPrefix.lowercaseString)
        
        return false
    }
    
    func hasFowardPrefix() -> Bool {
        //		guard let subject = self.subject else {
        //			return false
        //		}
        //
        //		return subject.lowercaseString.hasPrefix(forwardPrefix.lowercaseString)
        
        return false
        
    }
    
    func hasValidSubject() -> Bool {
        //		guard let subject = self.subject else {
        //			return false
        //		}
        //
        //		return !subject.isEmpty
        
        return false
    }
    
    func hasValidContent() -> Bool {
        //		guard let content = self.content else {
        //			return false
        //		}
        //
        //		return !content.isEmpty
        
        return false
        
    }
    
    func isValidToSend() -> Bool {
        //		return (recipients?.count > 0 && hasValidSubject() && hasValidSubject())
        
        return false
    }
    
    
    // MARK: Fetch Requests
    

    //
    //    class func fetchRequestForUploadCompletion() -> NSFetchRequest<NSFetchRequestResult> {
    //        let predicate = NSPredicate(format: "NONE attachments.upload_complete == NO")
    //        let secondPredicate = NSPredicate(format: "shouldBeSent == YES")
    //
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
    //        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, secondPredicate])
    //        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    //        return fetchRequest
    //    }
    //
    //    class func latestUpdatedMessageDate(inManagedContext context: NSManagedObjectContext) -> Date? {
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
    //        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
    //        fetchRequest.fetchBatchSize = 1
    //
    //        let results: [Message] = context.safeExecuteFetchRequest(fetchRequest)
    //
    //        if let lastMessageDate = results.first?.updatedAt {
    //            return lastMessageDate as Date
    //        }
    //        
    //        return nil
    //    }

}


enum Folder : String {
    case Inbox = "inbox"
    case Sent = "sent"
    case Archived = "archived"
    case Deleted = "deleted"
    case Draft = "draft"
}
