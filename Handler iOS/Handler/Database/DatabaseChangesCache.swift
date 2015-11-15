//
//  DatabaseChangesCache.swift
//  Handler
//
//  Created by Christian Praiss on 15/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class DatabaseChange: NSObject {
    var object: NSManagedObject
    var property: String
    var value: AnyObject?
    var executed = false
    
    init(object: NSManagedObject, property: String, value: AnyObject?){
        self.object = object
        self.property = property
        self.value = value
    }
    
    func apply() {
        // Use DE locale because first will always be uppercase
        object.setValue(value, forKey: property)
        self.executed = true;
    }
}

class DatabaseRelationshipChange: DatabaseChange {
    
    var remove: Bool
    
    init(remove: Bool, object: NSManagedObject, property: String, value: AnyObject){
        self.remove = remove
        super.init(object: object, property: property, value: value)
    }
    
    override func apply() {
        if let set = object.valueForKey(property) as? NSSet {
            var newSet: NSSet?
            if !remove {
                newSet = set.setByAddingObject(value!)
            }else{
                let newLabels = NSMutableSet(set: set)
                newLabels.removeObject(value!)
                newSet = newLabels as NSSet
            }
            object.setValue(newSet, forKey: property)
        }else{
            print("NSSet property not found on object of type \(object.entity.name)")
        }
        self.executed = true;
    }
}

class DatabaseChangesCache: NSObject {
    private var changesList: [NSManagedObjectID: [DatabaseChange]] = [NSManagedObjectID: [DatabaseChange]]()
    static let sharedInstance = DatabaseChangesCache()
    
    var allChangesApplied: Bool {
        get {
            var allEmpty = true
            
            // perform cleanup
            for key in changesList.keys {
                removeExecutedChangesForObjectID(key)
            }
            
            // check for unfinished operations
            for (_, value) in changesList {
                if(value.count > 0){
                    allEmpty = false
                }
            }
            return allEmpty
        }
    }
    
    func addChange(change: DatabaseChange){
        let objectID = change.object.objectID
        if let _ = self.changesList[objectID]{

        }else{
            self.changesList[objectID] = [DatabaseChange]()
        }
        self.changesList[objectID]?.append(change)
    }
    
    func executeChangesForObjectID(objectID: NSManagedObjectID) {
        if let arr = self.changesList[objectID] {
            for change in arr {
                change.apply()
            }
        }
    }
    
    func removeExecutedChangesForObjectID(objectID: NSManagedObjectID) {
        if let arr = self.changesList[objectID] {
            var nonExecutedChanges = [DatabaseChange]()
            for change in arr {
                if !change.executed {
                    nonExecutedChanges.append(change)
                }
            }
            self.changesList[objectID] = nonExecutedChanges
        }
    }
    
    func removeAllChangesForObjectID(objectID: NSManagedObjectID) {
        self.changesList[objectID]?.removeAll()
    }
}
