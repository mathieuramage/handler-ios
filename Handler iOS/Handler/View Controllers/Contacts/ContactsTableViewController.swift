//
//  ContactsTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 16/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		let fetchRequest = NSFetchRequest(entityName: "User")
//		let predicate = NSPredicate(format: "isContact == YES")
//		fetchRequest.predicate = predicate
		fetchRequest.fetchBatchSize = 20
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: MailDatabaseManager.sharedInstance.managedObjectContext, sectionNameKeyPath: "name", cacheName: nil)
		do{
			try fetchResultsController.performFetch()
		} catch {
			print(error)
		}
		
		return fetchResultsController
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactTableViewCell

        cell.user = fetchedResultsController.objectAtIndexPath(indexPath) as? User

        return cell
    }
	
	override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
		return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
	}
	
	override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
		return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(index)
	}
	
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (section < fetchedResultsController.sectionIndexTitles.count){
			return fetchedResultsController.sectionIndexTitles[section]
		}else{
			return nil
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let user = fetchedResultsController.objectAtIndexPath(indexPath) as? User {
			ContactCardViewController.showWithUser(user)
		}
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
