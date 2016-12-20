//
//  Label+CoreDataClass.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 18/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData


public class Label: NSManagedObject {

    convenience init(name: String, inContext context: NSManagedObjectContext) {
        self.init(managedObjectContext: context)
    }
    
}
