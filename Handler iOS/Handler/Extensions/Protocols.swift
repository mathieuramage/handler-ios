//
//  Protocols.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation
import CoreData
import HandlerSDK

// MARK: Database Type Conversino

protocol CoreDataConvertible {
	typealias HRType

	init(hrType: HRType, managedObjectContext: NSManagedObjectContext)
	static func fromHRType(hrType: HRType) -> Self?
	static func fromID(id: String) -> Self?
	func toHRType()->HRType
	static func fetchRequestForID(id: String) -> NSFetchRequest?
	static func backgroundFetchRequestForID(id: String) -> NSFetchRequest?
	func updateFromHRType(hrType: HRType)
}


// Default implementation
extension CoreDataConvertible where HRType : HRIDProvider  {
	
	static func fromHRType(hrType: HRType) -> Self? {
		guard let fetchrequest = self.backgroundFetchRequestForID(hrType.id) else {
			print("Failed to create fetchRequest for \(Self.self)")
			return nil
		}
		
		if let cdObject = MailDatabaseManager.sharedInstance.executeBackgroundFetchRequest(fetchrequest)?.first as? Self {
			//print("Found \(Self.self) in database")
			//cdObject.updateFromHRType(hrType)
			return cdObject
		}else{
			return Self(hrType: hrType, managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
		}
	}
	
	static func fromID(id: String) -> Self? {
		guard let fetchrequest = self.fetchRequestForID(id) else {
			print("Failed to create fetchRequest for object")
			return nil
		}
		
		return MailDatabaseManager.sharedInstance.executeBackgroundFetchRequest(fetchrequest)?.first as? Self
	}
}

// MARK: HRAction

protocol HRActionExecutable {
	func execute()
	func dependencyDidComplete(dependency: HRAction)
}

// MARK: UIViewController + show

protocol UIViewControllerShow {
	mutating func show()
	mutating func dismiss()
	var window: UIWindow? { get set }
}

extension UIViewControllerShow where Self: UIViewController {
	mutating func show(){
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.windowLevel = UIWindowLevelAlert - 1
		window?.rootViewController = self
		self.window?.makeKeyAndVisible()
		window?.alpha = 0
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.window?.alpha = 1
			}) { (success) -> Void in
		}
	}
}

// MARK: Observers

protocol MailboxCountObserver {
	func mailboxCountDidChange(mailboxType: MailboxType, newCount: Int)
}
extension Array {
	func randomItem() -> Element {
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self[index]
	}
}