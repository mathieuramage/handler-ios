//
//  InboxTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class InboxTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		let fetchRequest = NSFetchRequest(entityName: "Message")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sent_at", ascending: true)]
		return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: MailDatabaseManager.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print(error)
		}
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath)
		let message = fetchedResultsController.fetchedObjects![indexPath.row] as! Message
		cell.textLabel?.text = message.subject
		
		cell.detailTextLabel?.text = message.content
		
		return cell
	}
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		self.tableView.endUpdates()
	}
	
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		switch type {
		case NSFetchedResultsChangeType.Insert:
			self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Delete:
			self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
		default:
			break;
		}
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case NSFetchedResultsChangeType.Insert:
			self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Delete:
			self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Update:
			self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
		case NSFetchedResultsChangeType.Move:
			self.tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
		}
	}
}
