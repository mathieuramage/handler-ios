//
//  Message.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 16/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class Message: NSManagedObject {
    
    var folder : Folder {
        get {
            if let folderType = folderType, let folder = Folder(rawValue: folderType) {
                return folder
            }
            else {
                return .Inbox
            }
            
        }
    }
    
    var archived : Bool {
        get {
            return folder == .Archived
        }
    }
    
    fileprivate convenience init(json: JSON, inContext context: NSManagedObjectContext) {
        self.init(managedObjectContext: context)
        identifier = json["id"].stringValue
        ManagedMessage.setMessageDataWithJSON(message: self, json: json, context: context)
    }
    
    class func messageWithJSON(_ json: JSON, inContext context: NSManagedObjectContext) -> ManagedMessage {
        
        let identifier = json["id"].stringValue
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        fetchRequest.fetchBatchSize = 1
        
        if let message = (context.safeExecuteFetchRequest(fetchRequest) as [Message]).first {
            ManagedMessage.setMessageDataWithJSON(message: message, json: json, context: context)
            return message
        }
        
        let message = ManagedMessage(json: json, inContext: context)
        
        return message
    }
    
    class func setMessageDataWithJSON(message: Message, json : JSON, context: NSManagedObjectContext) {
        
        message.sender = User.userWithJSON(json["sender"], inContext: context)
        message.conversationId = json["conversationId"].stringValue
        
        message.conversation = Conversation.conversationWithID(message.conversationId!, inContext: context)
        
        message.subject = json["subject"].stringValue
        message.content = json["message"].stringValue
        
        if let recipientJsons = json["recipients"].array {
            for recipientJson in recipientJsons {
                let recipient = ManagedUser.userWithJSON(recipientJson, inContext: context)
                message.addRecipientsObject(recipient)
            }
        }
        
        message.read = json["isRead"].boolValue
        
        message.folderType = json["folder"].stringValue
        
        if let labelJsons = json["labels"].array {
            for labelJson in labelJsons {
                let label = ManagedLabel(id: labelJson.stringValue, inContext: context)
                label.message = message
            }
        }
        
        message.starred = json["isStar"].boolValue
        
        if let createdAtStr = json["createdAt"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            message.createdAt = formatter.date(from: createdAtStr) as! NSDate
        } else {
            message.createdAt = Date() as NSDate?
        }
        
        if let updatedAtStr = json["updatedAt"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            message.updatedAt = formatter.date(from: updatedAtStr) as! NSDate
        } else {
            message.updatedAt = NSDate()
        }
    }
    
    
    func moveToArchive() {
        self.removeLabelWithID(SystemLabels.Inbox.rawValue)
    }
    
    func moveToInbox() {
        self.addLabelWithID(SystemLabels.Inbox.rawValue)
    }
    
    func flag() {
        self.addLabelWithID(SystemLabels.Flagged.rawValue)
    }
    
    func unflag() {
        self.removeLabelWithID(SystemLabels.Flagged.rawValue)
    }
    
    func markAsRead() {
        // OTTODO Check this implementation
        self.removeLabelWithID(SystemLabels.Unread.rawValue)
    }
    
    func markAsUnread() {
        // OTTODO Check this implementation
        self.addLabelWithID(SystemLabels.Unread.rawValue)
    }
    
    // MARK: Refresh
    
    
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
        if let recipients = self.recipients?.allObjects as? [ManagedUser] {
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
    
    var isUnread: Bool {
        get {
            return !read
        }
    }
    
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
        get {
            return folderType == SystemLabels.Drafts.rawValue
        }
    }
    
    // TODO: Make it locale indepent
    let replyPrefix = "Re:"
    let forwardPrefix = "Fwd:"
    
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
    
    // MARK: Drafts
    
    func saveAsDraft() {
        //		self.addLabelWithID("DRAFT")
        //		self.sender = User.me()
    }
    
    func deleteFromDatabase() {
        let context = self.managedObjectContext
        
        context?.delete(self)
    }
    
    
    // MARK: Fetch Requests
    
    class func fetchRequestForMessagesWithInboxType(_ type: MailboxType) -> NSFetchRequest<NSFetchRequestResult> {
        
        switch type {
        case .AllChanges :
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedMessage.entityName())
            fetchRequest.fetchBatchSize = 20
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        case .Inbox :
            let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.folderType == %@).@count != 0", Folder.Inbox.rawValue)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Conversation.entityName())
            fetchRequest.fetchBatchSize = 20
            fetchRequest.predicate = predicate
            // OTTODO: It should be sorted by date.
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
            return fetchRequest
            
        case .Unread :
            let predicate = NSPredicate(format: "SUBQUERY(messages, $t, $t.read != nil && $t.read == NO).@count != 0")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Conversation.entityName())
            fetchRequest.predicate = predicate
            fetchRequest.fetchBatchSize = 20
            // OTTODO: It should be sorted by date.
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
            return fetchRequest
            
        case .Sent :
            let predicate = NSPredicate(format: "folderType == %@", Folder.Sent.rawValue)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        case .Flagged:
            let predicate = NSPredicate(format: "starred != nil && starred == YES")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        case .Drafts:
            let predicate = NSPredicate(format: "folderType == %@", Folder.Draft.rawValue)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return fetchRequest
            
        default :
            if type != .Archive {
                return fetchRequestForMessagesWithLabelWithId(type.rawValue)
            } else {
                // handle archive case
                let predicate = NSPredicate(format: "folderType == %@", Folder.Archived.rawValue)
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
                fetchRequest.fetchBatchSize = 20
                fetchRequest.predicate = predicate
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                return fetchRequest
            }
        }
        
    }
    
    class func fetchRequestForMessagesWithLabelWithId(_ id: String) -> NSFetchRequest<NSFetchRequestResult> {
        let predicate = NSPredicate(format: "ANY labels.id == %@", id)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return fetchRequest
    }
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
