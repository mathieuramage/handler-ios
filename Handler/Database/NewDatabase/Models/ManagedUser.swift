//
//  User.swift
//  
//
//  Created by Otávio on 18/09/16.
//
//

import Foundation
import CoreData
import SwiftyJSON

class ManagedUser: NSManagedObject {

	/*
	twitter.id	String	Required | Unique
	twitter.username	String	# Can be empty
	twitter.name	String	# Can be empty
	twitter.pictureUrl	String	# Can be empty
	twitter.description	String	# Can be empty
	devices	ObjectID	# Can be empty
	friendsCount	Number	# Can be empty
	role	String	Required | Default: ‘draft’ | Enum: ['inbox', 'sent', 'archived', 'deleted', 'draft']
	riskRating	Number	Default: 0
	userStatus	String	Required | Default: ‘active’ | Enum: ['active', 'deactivated', 'blocked']
	flags.createdAt	Date	# Can be empty
	flags.createdBy	User	# Can be empty
	threeRatingSince	Date	# Can be empty
	fiveRatingSince	Date	# Can be empty
	tenRatingSince	Date	# Can be empty
	blockedOn	Date	# Can be empty
	deactivatedOn	Date	# Can be empty
	noProfileLocation	Boolean	Default: true
	emailThreads	Number	Default: 0
	signInsSimultaneous	Number	Default: 1

	*/

//	var twitterUser : TwitterUser?
	var devices : [String]? //??
	var friendsCount : Int?
	var role : String?
	var status : UserStatus?
	//TODO
	var emailThreadCount : Int?

	var handle : String = ""

	var pictureUrlString: String?
	var pictureUrl : NSURL? {
		get {
			if let pictureUrlString = pictureUrlString {
				return NSURL(string: pictureUrlString)
			}

			return nil
		}
	}

	convenience init(managedObjectContext: NSManagedObjectContext) {
		let entityName = "User"
		let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)!

		self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
	}

	convenience init(json: JSON, inContext context: NSManagedObjectContext) {
		self.init(managedObjectContext: context)

		identifier = json["id"].stringValue

		// This is not coming in the JSON
//		twitterUser = TwitterUser(json: json["twitter"])

		pictureUrlString = json["profile_picture_url"].stringValue
		handle = json["handle"].stringValue
		name = json["name"].stringValue
		friendsCount = json["friendsCount"].int
		role = json["role"].string
		riskRating = json["riskRating"].intValue

		status = UserStatus(rawValue: json["userStatus"].stringValue)

		//flags?
		emailThreadCount = json["emailThreads"].intValue
	}

	convenience init(handle: String, inManagedContext context: NSManagedObjectContext) {
		// OTTODO: Implement this
		
		self.init(managedObjectContext: context)
	}

	class func me() -> ManagedUser? {
		// OTTODO: Implement this

		return nil
	}

	class func userWithHandle(handle: String, inContext context: NSManagedObjectContext? = nil) -> ManagedUser {
		let internalContext = context ?? DatabaseManager.sharedInstance.mainManagedContext

		if let user = (internalContext.safeExecuteFetchRequest(ManagedUser.fetchRequestForHandle(handle)) as? [ManagedUser])?.first {
			return user
		}
		else {
			return ManagedUser(handle: handle, inManagedContext: internalContext)
		}
	}

	class func fetchRequestForHandle(handle: String) -> NSFetchRequest {
		let fetchRequest = NSFetchRequest(entityName: self.entityName())
		fetchRequest.predicate = NSPredicate(format: "%K == %@", "handle", handle)
		return fetchRequest
	}

}

enum UserStatus : String {
	case Active = "active"
	case Deactivated = "deactivated"
	case Blocked = "blocked"
}
