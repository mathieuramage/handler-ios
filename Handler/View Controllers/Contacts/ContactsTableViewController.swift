//
//  ContactsTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import CoreData

@objc protocol ContactSelectionDelegate {
	func didSelectUser(_ user: User)
	@objc optional func didCancel()
}

class ContactsTableViewController: UITableViewController {
	
	var userSelectionDelegate: ContactSelectionDelegate?
    
//	lazy var fetchedResultsController: NSFetchedResultsController = { () -> <<error type>> in
//		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//		fetchRequest.fetchBatchSize = 20
//		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
//		let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DatabaseManager.sharedInstance.mainManagedContext, sectionNameKeyPath: "name", cacheName: nil)
//		do{
//			try fetchResultsController.performFetch()
//		} catch {
//			print(error)
//		}
//		
//		return fetchResultsController
//	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
//        return fetchedResultsController.sections?.count ?? 0
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactLegacyTableViewCell

//        cell.user = fetchedResultsController.object(at: indexPath) as? User

        return cell
    }
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return UILocalizedIndexedCollation.current().sectionIndexTitles
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index)
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		if (section < fetchedResultsController.sectionIndexTitles.count){
//			return fetchedResultsController.sectionIndexTitles[section]
//		} else {
//			return nil
//		}
        return nil
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		if let user = fetchedResultsController.objectAtIndexPath(indexPath) as? LegacyUser {
//			if let delegate = self.userSelectionDelegate {
//				delegate.didSelectUser(user)
//			}else {
//				ContactCardViewController.showWithUser(user)
//			}
//		}
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
