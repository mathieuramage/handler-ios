//
//  ContactsAutoCompleteViewController.swift
//  Handler
//
//  Created by Otávio on 13/02/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol AutoCompleteDelegate {
    
    func contactsAutoCompleteDidSelectUser(controller: ContactsAutoCompleteViewController, user: User)
}

private struct MatchedUser {
    
    let user: User
    let handleMatchRange: Range<String.Index>?
    let nameMatchRange: Range<String.Index>?
    
    init(user: User, handleMatchRange: Range<String.Index>?, nameMatchRange: Range<String.Index>?) {
        self.user = user
        self.handleMatchRange = handleMatchRange
        self.nameMatchRange = nameMatchRange
    }
    
}

private struct AutoCompleteMatcher {
    
    let predicate: NSPredicate
    
    init(predicate: NSPredicate) {
        self.predicate = predicate
    }
    
    func evaluate(user: User, searchedText: String) -> MatchedUser? {
        let match = self.predicate.evaluateWithObject(user)
        
        if match {
            let normalizedSearchedText = searchedText.stringByFoldingWithOptions([.DiacriticInsensitiveSearch, .CaseInsensitiveSearch], locale: nil)
            
            let handleRange = user.handle?.stringByFoldingWithOptions([.DiacriticInsensitiveSearch, .CaseInsensitiveSearch], locale: nil).rangeOfString(normalizedSearchedText)
            
            let nameRange = user.name?.stringByFoldingWithOptions([.DiacriticInsensitiveSearch, .CaseInsensitiveSearch], locale: nil).rangeOfString(normalizedSearchedText)
            
            return MatchedUser(user: user, handleMatchRange: handleRange, nameMatchRange: nameRange)
        }
        
        return nil
    }
}

class ContactsAutoCompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let AutoCompleteCellID = "ContactsCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    private var matchedUsers = [MatchedUser]()
    
    var delegate: AutoCompleteDelegate? = nil
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: User.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "handle", ascending: true)]
        
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: MailDatabaseManager.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedController.performFetch()
        }
        catch {
            print(error)
        }
        
        return fetchedController
    }()
    
    var fetchedUsers: [User] {
        get {
            return fetchedResultsController.fetchedObjects as? [User] ?? [User]()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "ContactAutocompleteCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier:ContactsAutoCompleteViewController.AutoCompleteCellID)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self        
    }
    
    // MARK: TableView DataSource & Delegate
    
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.view.hidden = matchedUsers.count == 0
        
        return matchedUsers.count
    }
    
    internal func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ContactsAutoCompleteViewController.AutoCompleteCellID, forIndexPath: indexPath) as! ContactAutocompleteCell
        
        guard indexPath.row < matchedUsers.count else {
            return cell
        }
        
        let matchedUser = matchedUsers[indexPath.row]
        
        if let name = matchedUser.user.name {
            if let matchedNameRange = matchedUser.nameMatchRange {
                let attributedString = NSMutableAttributedString(string: name, attributes: [ NSForegroundColorAttributeName: UIColor(rgba: HexCodes.gray)])
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgba: HexCodes.darkGray), range: name.NSRangeFromRange(matchedNameRange))
                
                cell.contactName.attributedText = attributedString
            }
            else {
                cell.contactName.text = name
            }
            
        }
        else {
            cell.contactName.text = nil
        }
        
        if let handle = matchedUser.user.handle {
            if let matchedNameRange = matchedUser.handleMatchRange {
                let attributedString = NSMutableAttributedString(string: handle, attributes: [ NSForegroundColorAttributeName: UIColor(rgba: HexCodes.gray)])
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgba: HexCodes.darkGray), range: handle.NSRangeFromRange(matchedNameRange))
                
                let attributedWithAtSymbol = NSMutableAttributedString(string: "@", attributes: [ NSForegroundColorAttributeName: UIColor(rgba: HexCodes.gray)])
                attributedWithAtSymbol.appendAttributedString(attributedString)
                cell.contactHandle.attributedText = attributedWithAtSymbol
            }
            else {
                cell.contactHandle.text = "@" + handle
            }
        }
            
        else {
            cell.contactHandle.text = nil
        }
        
        if let urlString = matchedUser.user.profile_picture_url, let profileURL = NSURL(string: urlString) {
            cell.contactPhoto.kf_setImageWithURL(profileURL, placeholderImage: UIImage.randomGhostImage(), optionsInfo: nil, completionHandler:nil)
        }
        else {
            cell.contactPhoto.image = UIImage.randomGhostImage()
        }
        
        return cell
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        delegate?.contactsAutoCompleteDidSelectUser(self, user: matchedUsers[indexPath.row].user)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Public functions
    
    func autoCompleteUserForPrefix(string : String) {
        let handleBeginsWithPredicate = NSPredicate(format: "handle BEGINSWITH[cd] %@", argumentArray: [string])
        let nameBeginsWithPredicate = NSPredicate(format: "name BEGINSWITH[cd] %@", argumentArray: [string])
        let handleContainsWithPredicate = NSPredicate(format: "handle CONTAINS[cd] %@", argumentArray: [string])
        let nameContainsWithPredicate = NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [string])
        
        let predicatesByPriority = [
            AutoCompleteMatcher(predicate: handleBeginsWithPredicate),
            AutoCompleteMatcher(predicate: nameBeginsWithPredicate),
            AutoCompleteMatcher(predicate: handleContainsWithPredicate),
            AutoCompleteMatcher(predicate: nameContainsWithPredicate),
        ]
        
        var sortedMatchedUsers = [MatchedUser]()
        
        for matcher in predicatesByPriority {
            for user in fetchedUsers {
                if let matchedUser = matcher.evaluate(user, searchedText: string) {
                    if sortedMatchedUsers.contains({ $0.user == matchedUser.user }) {
                        continue
                    }
                    sortedMatchedUsers.append(matchedUser)
                }
            }
        }
        
        matchedUsers = Array(sortedMatchedUsers)
        
        self.tableView.reloadData()
    }
}

extension String {
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.startIndex, within: utf16view)
        let to = String.UTF16View.Index(range.endIndex, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
    }
}
