//
//  ConversationOperations.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 04/09/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct ConversationOperations {
    
    static func refreshConversations(callback : @escaping (_ success : Bool, _ allConversations : [Conversation]) -> ()) {
        
        let lastUpdated = Message.latestUpdatedMessageDate(inManagedContext: PersistenceManager.mainManagedContext)
        getAllConversations(before: Date(), after: lastUpdated as Date?, limit: nil) { (success, conversations) in
            callback(success, conversations ?? [])
        }
    }
    
    static func getAllConversations(before : Date? , after : Date?, limit : Int?, callback : @escaping (_ success : Bool, _ conversations : [Conversation]?) -> ()) {
        
        MessageOperations.getAllMessages(before: before, after: after, limit: limit) { (success, messages) in
            callback(success, nil)
        }
    }
    
    typealias ConversationUpdateCallback = (_ success : Bool) -> ()
    
    static func deleteConversation(conversationId : String, callback : ConversationUpdateCallback?) {
        moveConversationToFolder(conversationId: conversationId, folder: .Deleted, callback: callback)
    }
    
    static func archiveConversation(conversationId : String, callback : ConversationUpdateCallback?) {
        moveConversationToFolder(conversationId: conversationId, folder: .Archived, callback: callback)
    }
    
    static func moveConversationToFolder(conversationId : String, folder : Folder, callback : ConversationUpdateCallback?) {
        var conversationData = ConversationData(conversationId: conversationId)
        conversationData.folder = folder
        postConversation(conversationData, callback: callback)
    }
    
    static func markConversationAsRead(conversationId : String, read : Bool, callback : ConversationUpdateCallback?) {
        var conversationData = ConversationData(conversationId: conversationId)
        conversationData.read = read
        postConversation(conversationData, callback: callback)
    }
    
    static func markConversationStarred(conversationId : String, starred : Bool, callback : ConversationUpdateCallback?) {
        var conversationData = ConversationData(conversationId: conversationId)
        conversationData.starred = starred
        postConversation(conversationData, callback: callback)
    }
    
    static func updateConversationLabels(conversationId: String, labels : [String], callback : ConversationUpdateCallback?) {
        var conversationData = ConversationData(conversationId: conversationId)
        conversationData.labels = labels
        postConversation(conversationData, callback: callback)
    }
    
    
    fileprivate static func postConversation(_ conversationData : ConversationData, callback : ConversationUpdateCallback?) {
        
        let route = Config.APIRoutes.conversation(conversationData.conversationId)
        
        var params = [String : AnyObject]()
        
        if let folder = conversationData.folder {
            params["folder"] = folder.rawValue as AnyObject?
        }
        
        if let read = conversationData.read {
            params["isRead"] = read as AnyObject?
        }
        
        if let labels = conversationData.labels {
            params["labels"] = labels as AnyObject?
        }
        
        if let starred = conversationData.starred {
            params["isStar"] = starred as AnyObject?
        }
        
        APIUtility.request(method: .post, route: route, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success:
                callback?(true)
            case .failure(_):
                callback?(false)
            }
        }       
        
    }
}


struct ConversationData {
    
    init(conversationId : String) {
        self.conversationId = conversationId
    }
    
    var conversationId : String
    var folder : Folder?
    var read : Bool?
    var labels : [String]?
    var starred : Bool?
}
