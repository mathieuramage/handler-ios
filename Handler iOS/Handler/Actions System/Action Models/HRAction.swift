//
//  HRAction.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
@objc
class HRAction: NSManagedObject, HRActionExecutable {
	
	func execute() {
		
	}
	
	func dependencyDidComplete(dependency: HRAction) {
		
	}
}
