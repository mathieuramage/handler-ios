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

	lazy var fetchedResultsController: NSFetchedResultsController<User> = {
		let fetchRequest = NSFetchRequest<User>(entityName: "User")
		fetchRequest.fetchBatchSize = 20
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "twitterUser.name", ascending: true)]
		let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: "twitterUser.name", cacheName: nil)
		do {
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

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactLegacyTableViewCell

		cell.user = fetchedResultsController.object(at: indexPath)

		return cell
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return UILocalizedIndexedCollation.current().sectionIndexTitles
	}

	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index)
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (section < fetchedResultsController.sectionIndexTitles.count) {
			return fetchedResultsController.sectionIndexTitles[section]
		} else {
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = fetchedResultsController.object(at: indexPath)

		if let delegate = self.userSelectionDelegate {
			delegate.didSelectUser(user)
		} else {
			ContactCardViewController.showWithUser(user)
		}
	}
}
