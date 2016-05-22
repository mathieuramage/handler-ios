//
//  HRAction.swift
//  Handler
//
//  Created by Christian Praiss on 12/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
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
