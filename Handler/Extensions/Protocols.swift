//
//  Protocols.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
import HandlerSDK

// MARK: Database Type Conversino

protocol CoreDataConvertible {
	associatedtype HRType

	init(hrType: HRType, managedObjectContext: NSManagedObjectContext)
	static func fromHRType(hrType: HRType) -> Self?
	static func fromID(id: String) -> Self?
	func toHRType() -> HRType
	static func fetchRequestForID(id: String) -> NSFetchRequest?
	static func backgroundFetchRequestForID(id: String) -> NSFetchRequest?
	func updateFromHRType(hrType: HRType)
	func toManageObjectContext(context: NSManagedObjectContext) -> Self?
}


// Default implementation
extension CoreDataConvertible where HRType : HRIDProvider {

	static func fromHRType(hrType: HRType) -> Self? {
		if APICommunicator.sharedInstance.allowsObjectCreation {
			guard let fetchrequest = self.backgroundFetchRequestForID(hrType.id) else {
				print("Failed to create fetchRequest for \(Self.self)")
				return nil
			}

			if let cdObject = MailDatabaseManager.sharedInstance.executeBackgroundFetchRequest(fetchrequest)?.first as? Self {
				 cdObject.updateFromHRType(hrType)
				return cdObject
			} else {
				return Self(hrType: hrType, managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
			}
		} else {
			print("datastore blocked")
			return nil
		}
	}

	static func fromID(id: String) -> Self? {
		guard let fetchrequest = self.fetchRequestForID(id) else {
			print("Failed to create fetchRequest for object")
			return nil
		}
		
		return MailDatabaseManager.sharedInstance.executeBackgroundFetchRequest(fetchrequest)?.first as? Self
	}

	func toManageObjectContext(context: NSManagedObjectContext) -> Self? {
		return context.objectWithID((self as! NSManagedObject).objectID) as? Self
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
	func dismissPressed(sender: AnyObject?)
}

extension UIViewControllerShow where Self: UIViewController {
	mutating func show(){
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.windowLevel = UIWindowLevelAlert - 1
		window?.rootViewController = self
        window?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissPressed:")))
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