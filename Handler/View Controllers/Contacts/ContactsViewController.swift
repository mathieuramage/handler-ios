//
//  ContactsViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 22/4/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import AddressBook
import Contacts
import Async

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var searchBar: UISearchBar!

	@IBOutlet weak var followersButton: UIButton!
	@IBOutlet weak var followingButton: UIButton!
	@IBOutlet weak var deviceButton: UIButton!
	@IBOutlet weak var borderView: UIView!
	
	@IBOutlet weak var authorizationSwitch: UISwitch!
	@IBOutlet weak var contactHeaderView: UIView!
	@IBOutlet weak var ticketsHeaderView: UIView!
	
	var twitterFollowerList: [TwitterUserData] = []
	var twitterFollowingList : [TwitterUserData] = []
	var deviceContactList : [APContact] = []

	let addressBook = APAddressBook()

	var followerNextCursor : Int?
	var followingNextCursor : Int?
	var selectedTab : Int = 0
	
	@IBAction func toggleSwitched(_ sender: UISwitch) {
		if !authorizationSwitch.isSelected {
			activityIndicator.startAnimating()
			if self.deviceContactList.isEmpty {
				setupDeviceContacts()
				fetchDeviceContactList()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		selectTab(0)
		selectButton(self.followersButton)
		borderView.layer.cornerRadius = 5
		borderView.clipsToBounds = true
		borderView.layer.borderWidth = 1
		borderView.layer.borderColor = borderView.tintColor.cgColor
		searchBar.placeholder = "Search for people"
		searchBar.backgroundColor = UIColor(red: 194/255, green: 202/255, blue: 215/255, alpha: 1.0)
		searchBar.barTintColor = UIColor(red: 194/255, green: 202/255, blue: 215/255, alpha: 1.0)
		searchBar.backgroundImage = UIImage()
		searchBar.delegate = self
		navigationController?.navigationBar.shadowImage = UIImage()
		contactHeaderView.frame = CGRect(x: 0, y: 0, width: contactHeaderView.frame.width, height: 110)
		contactHeaderView.isHidden = true
		ticketsHeaderView.layer.opacity = 0
		self.automaticallyAdjustsScrollViewInsets = false
		self.tableView.contentInset.top = 50.0
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let navButtons = self.navigationController?.navigationBar.items, navButtons.count > 0{
			navButtons[0].title = ""
		}

		activityIndicator.startAnimating()

		TwitterAPIOperations.getTwitterFollowers(nil) { (users, nextCursor) in
			self.twitterFollowerList = users
			self.followerNextCursor = nextCursor
			if self.selectedTab == 0 {
				self.activityIndicator.stopAnimating()
				self.tableView.reloadData()
			}

		}

		TwitterAPIOperations.getTwitterFriends(nil) { (users, nextCursor) in
			self.twitterFollowingList = users
			self.followingNextCursor = nextCursor

			if self.selectedTab == 1 {
				self.activityIndicator.stopAnimating()
				self.tableView.reloadData()
			}
		}
	}
	
	func areContactsAuthrorized() -> Bool {
		return CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .authorized
	}

	// MARK: Search Bar Functions

	// TODO: Perform search here.
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.resignFirstResponder()
		navigationController?.setNavigationBarHidden(false, animated: true)
	}

	func fetchMoreFromTwitter() {
		if selectedTab == 0 {
			if let cursor = followerNextCursor {
				TwitterAPIOperations.getTwitterFollowers(cursor) { (users, nextCursor) in
					self.twitterFollowerList.append(contentsOf: users)
					self.followerNextCursor = nextCursor
					self.tableView.reloadData()
				}
			}

		} else if selectedTab == 1 {

			if let cursor = followingNextCursor {
				TwitterAPIOperations.getTwitterFriends(cursor) { (users, nextCursor) in
					self.twitterFollowingList.append(contentsOf: users)
					self.followingNextCursor = nextCursor
					self.tableView.reloadData()
				}
			}

		}
	}
	
	func showTicketsHeaderView() {
		UIView.animate(withDuration: 0.5) {
			self.ticketsHeaderView.layer.opacity = 1
		}
	}
	
	func hideHeaderView() {
		contactHeaderView.frame = CGRect(x: 0, y: 0, width: self.contactHeaderView.frame.width, height: 0)
		contactHeaderView.layer.opacity = 0
		contactHeaderView.isHidden = true
		view.layoutIfNeeded()
	}
	
	func showHeaderView() {
		self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: self.contactHeaderView.frame.width, height: 110)
		contactHeaderView.layer.opacity = 1
		contactHeaderView.isHidden = false
		view.layoutIfNeeded()
	}

	func setupDeviceContacts() {
		self.addressBook.fieldsMask = [.default, .thumbnail, .websites]
		self.addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
		                                    NSSortDescriptor(key: "name.lastName", ascending: true)]

		self.addressBook.startObserveChanges(callback: {
			[unowned self] in
			self.fetchDeviceContactList()
		})
	}

	func fetchDeviceContactList() {
		self.addressBook.loadContacts(
			{ (contacts: [APContact]?, error: Error?) in
				self.deviceContactList = contacts ?? []
				self.showTicketsHeaderView()
				self.activityIndicator.stopAnimating()
				self.tableView.reloadData()
		})
	}

	// MARK: - UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		switch selectedTab {
		case 0:
			return twitterFollowerList.count
		case 1:
			return twitterFollowingList.count
		case 2:
			return deviceContactList.count
		default :
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64.0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "contactTableViewCell", for: indexPath) as! ContactTableViewCell

		let user = activeTabContacts[indexPath.row]

		cell.handleLabel.text = user.handle() ?? "No Twitter username found"
		cell.nameLabel.text = user.named()
		
		if user.handle() == nil {
			cell.followButton.setImage(UIImage(named: "contacts_invite_button_icon"), for: .normal)
		}

		if let url = user.profilePictureURL() {
			cell.profileImageView.kf.setImage(with: url, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)
		} else {
			cell.profileImageView.image = UIImage.randomGhostImage()
		}

		if selectedTab < 2 && indexPath.row == activeTabContacts.count - 3 { // near the end of the list, fetch more from twitter
			fetchMoreFromTwitter()
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)

		// FIXME: This method expects a User but we have either TwitterData or APContact
		// ContactCardViewController.showWithUser(user)
	}

	// MARK - Segmented Button Actions and Helpers

	@IBAction func followersButtonTapped(_ sender: AnyObject) {
		selectTab(0)
		hideHeaderView()
	}

	@IBAction func followingButtonTapped(_ sender: AnyObject) {
		selectTab(1)
		hideHeaderView()
	}

	@IBAction func deviceButtonTapped(_ sender: AnyObject) {
		if areContactsAuthrorized() {
			ticketsHeaderView.layer.opacity = 1
			setupDeviceContacts()
			fetchDeviceContactList()
		}
		
		selectTab(2)
		showHeaderView()
	}

	var activeTabContacts : [ListableAsContact] {
		get {
			switch selectedTab {
			case 0:
				return twitterFollowerList
			case 1:
				return twitterFollowingList
			case 2:
				return deviceContactList
			default :
				return [] // Should never reach here
			}
		}
	}

	func selectTab(_ index : Int) {

		if selectedTab == index {
			return
		}
		resetButtons()
		selectedTab = index

		switch index {
		case 0:
			selectButton(followersButton)
		case 1:
			selectButton(followingButton)
		case 2:
			selectButton(deviceButton)
		default:
			break
		}
		Async.main {
			let offset = CGPoint.init(x: 0, y: -50)
			self.tableView.setContentOffset(offset, animated: false)
		}

		if activeTabContacts.count > 0 {
			activityIndicator.stopAnimating()
		}
		tableView.reloadData()
	}

	fileprivate func selectButton(_ button : UIButton) {
		button.isSelected = true
		UIView.animate(withDuration: 0.1, animations: {
			button.backgroundColor = UIColor(rgba: "#55AEEB")
		})
	}

	func resetButtons() {
		followersButton.isSelected = false
		followingButton.isSelected = false
		deviceButton.isSelected = false
		followersButton.backgroundColor = UIColor.white
		followingButton.backgroundColor = UIColor.white
		deviceButton.backgroundColor = UIColor.white
	}
}

extension String {

	func extractTwiterHandleFromURL() -> String? {
		let range = NSMakeRange(0, characters.count)
		let regex = try! NSRegularExpression(pattern: "^http(s)?://(www.)?twitter.com/(#!/)?", options: [.caseInsensitive])

		if let _ = regex.firstMatch(in: self, options: [], range: range) {
			let handle = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")

			if handle.characters.count > 0 {
				return handle
			}
		}

		return nil
	}
}

protocol ListableAsContact {

	// "Name" would be a better function naming here but it generates conflicts with Obj-C classes
	// Simplest solution is this "workaround"
	func named() -> String?

	func handle() -> String?

	func profilePictureURL() -> URL?
}

extension APContact: ListableAsContact {

	func named() -> String? {
		return name?.compositeName
	}

	func handle() -> String? {
		guard let websites = websites else {
			return nil
		}

		for website in websites {
			if let handle = website.extractTwiterHandleFromURL() {
				return "@" + handle
			}
		}

		return nil
	}

	func profilePictureURL() -> URL? {
		return nil
	}
}

extension TwitterUserData: ListableAsContact {

	func named() -> String? {
		return name
	}

	func handle() -> String? {
		return "@" + (username ?? "")
	}

	func profilePictureURL() -> URL? {
		guard let url = pictureURLString else {
			return nil
		}
		
		return URL(string: url)
	}
	
}
