//
//  ContactsAutoCompleteViewController.swift
//  Handler
//
//  Created by Otávio on 13/02/16.
//  Updated by Cagdas Altinkaya on 03/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol AutoCompleteDelegate {
    
    func contactsAutoCompleteDidSelectUser(_ controller: ContactsAutoCompleteViewController, user: User)
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
    
    func evaluate(_ user: User, searchedText: String) -> MatchedUser? {
        let match = self.predicate.evaluate(with: user)
        
        if match {
            let normalizedSearchedText = searchedText.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            
            let handleRange = user.handle.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).range(of: normalizedSearchedText)
            
            let nameRange = user.name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).range(of: normalizedSearchedText)
            
            return MatchedUser(user: user, handleMatchRange: handleRange, nameMatchRange: nameRange)
        }
        
        return nil
    }
}

class ContactsAutoCompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let AutoCompleteCellID = "ContactsCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var matchedUsers = [MatchedUser]()
    
    var delegate: AutoCompleteDelegate? = nil
    
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        let fetchRequest = NSFetchRequest(entityName: LegacyUser.entityName())
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "handle", ascending: true)]
//        
//        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: MailDatabaseManager.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//        
//        do {
//            try fetchedController.performFetch()
//        }
//        catch {
//            print(error)
//        }
//        
//        return fetchedController
//    }()
//    
//    var fetchedUsers: [LegacyUser] {
//        get {
//            return fetchedResultsController.fetchedObjects as? [LegacyUser] ?? [LegacyUser]()
//        }
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ContactAutocompleteCell", bundle: Bundle.main), forCellReuseIdentifier:ContactsAutoCompleteViewController.AutoCompleteCellID)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self        
    }
    
    // MARK: TableView DataSource & Delegate
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.view.isHidden = matchedUsers.count == 0
        
        return matchedUsers.count
    }
    
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsAutoCompleteViewController.AutoCompleteCellID, for: indexPath) as! ContactAutocompleteCell
        
        guard indexPath.row < matchedUsers.count else {
            return cell
        }
        
        let matchedUser = matchedUsers[indexPath.row]

		let name = matchedUser.user.name
        if name?.characters.count > 0 {
            if let matchedNameRange = matchedUser.nameMatchRange {
                let attributedString = NSMutableAttributedString(string: name!, attributes: [ NSForegroundColorAttributeName: UIColor(rgba: HexCodes.gray)])
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgba: HexCodes.darkGray), range: name!.NSRangeFromRange(matchedNameRange))
                
                cell.contactName.attributedText = attributedString
            }
            else {
                cell.contactName.text = name
            }
            
        }
        else {
            cell.contactName.text = nil
        }

		let handle = matchedUser.user.handle
        if  handle.characters.count > 0{
            if let matchedNameRange = matchedUser.handleMatchRange {
                let attributedString = NSMutableAttributedString(string: handle, attributes: [ NSForegroundColorAttributeName: UIColor(rgba: HexCodes.gray)])
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgba: HexCodes.darkGray), range: handle.NSRangeFromRange(matchedNameRange))
                
                let attributedWithAtSymbol = NSMutableAttributedString(string: "@", attributes: [ NSForegroundColorAttributeName: UIColor(rgba: HexCodes.gray)])
                attributedWithAtSymbol.append(attributedString)
                cell.contactHandle.attributedText = attributedWithAtSymbol
            }
            else {
                cell.contactHandle.text = "@" + handle
            }
        }
            
        else {
            cell.contactHandle.text = nil
        }
        
		if let pictureUrl = matchedUser.user.pictureUrl {
            cell.contactPhoto.kf.setImage(with: pictureUrl, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            cell.contactPhoto.image = UIImage.randomGhostImage()
        }
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        delegate?.contactsAutoCompleteDidSelectUser(self, user: matchedUsers[indexPath.row].user)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public functions
    
    func autoCompleteUserForPrefix(_ string : String) {
//        let handleBeginsWithPredicate = NSPredicate(format: "handle BEGINSWITH[cd] %@", argumentArray: [string])
//        let nameBeginsWithPredicate = NSPredicate(format: "name BEGINSWITH[cd] %@", argumentArray: [string])
//        let handleContainsWithPredicate = NSPredicate(format: "handle CONTAINS[cd] %@", argumentArray: [string])
//        let nameContainsWithPredicate = NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [string])
//        
//        let predicatesByPriority = [
//            AutoCompleteMatcher(predicate: handleBeginsWithPredicate),
//            AutoCompleteMatcher(predicate: nameBeginsWithPredicate),
//            AutoCompleteMatcher(predicate: handleContainsWithPredicate),
//            AutoCompleteMatcher(predicate: nameContainsWithPredicate),
//        ]
//        
//        var sortedMatchedUsers = [MatchedUser]()
//        
//        for matcher in predicatesByPriority {
//            for user in fetchedUsers {
//                if let matchedUser = matcher.evaluate(user, searchedText: string) {
//                    if sortedMatchedUsers.contains({ $0.user == matchedUser.user }) {
//                        continue
//                    }
//                    sortedMatchedUsers.append(matchedUser)
//                }
//            }
//        }
//        
//        matchedUsers = Array(sortedMatchedUsers)

        self.tableView.reloadData()
    }
}

extension String {
    func NSRangeFromRange(_ range : Range<String.Index>) -> NSRange {
//        let utf16view = self.utf16
//        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
//        let to = String.UTF16View.Index(range.upperBound, within: utf16view)
//        return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
        return NSRange()
    }
}
