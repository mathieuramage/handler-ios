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

protocol ContactSelectionDelegate {
	func didSelectHandlerUser(_ handle: String)
}

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
	@IBOutlet weak var authorizationHeaderView: UIView!
	
	@IBOutlet weak var tableHeaderView: UIView!
	
	let addressBook = APAddressBook()
	let NO_MORE_RESULTS = 0
	
	var twitterFollowerList: [TwitterUserData] = []
	var twitterFollowingList: [TwitterUserData] = []
	var deviceContactList: [APContact] = []
	
	var allFollowers: [TwitterUserData] = []
	var allFollowing: [TwitterUserData] = []
	var allContacts: [APContact] = []

	var followerNextCursor : Int?
	var followingNextCursor : Int?
	var selectedTab : Int = 0
	
	var contactSelectionDelegate: ContactSelectionDelegate?
	
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
		selectButton(self.followingButton)
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
		hideHeaderView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let navButtons = self.navigationController?.navigationBar.items, navButtons.count > 0{
			navButtons[0].title = ""
		}

		activityIndicator.startAnimating()

		TwitterAPIOperations.getTwitterFriends(nil) { (users, nextCursor) in
			self.twitterFollowingList = users
			self.allFollowing = self.twitterFollowingList
			self.followingNextCursor = nextCursor
			self.sortFollowingsAsc()
			if self.selectedTab == 0 {
				self.activityIndicator.stopAnimating()
				self.tableView.reloadData()
			}
		}
		TwitterAPIOperations.getTwitterFollowers(nil) { (users, nextCursor) in
			self.twitterFollowerList = users
			self.allFollowers = self.twitterFollowerList
			self.followerNextCursor = nextCursor
			self.sortFollowersAsc()
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
	
	private func filterFollowingsByNameOrHandle(searchText: String) {
		twitterFollowingList = allFollowing.filter { contact in
			let text = searchText.lowercased()
			let handle = contact.handle() ?? ""
			let user = contact.name ?? ""
			
			return handle.lowercased().contains(text) ? handle.lowercased().contains(text) : user.lowercased().contains(text)
		}
		tableView.reloadData()
	}
	
	private func filterFollowersByNameOrHandle(searchText: String) {
		twitterFollowerList = allFollowers.filter { contact in
			let text = searchText.lowercased()
			let handle = contact.handle() ?? ""
			let user = contact.name ?? ""
			
			return handle.lowercased().contains(text) ? handle.lowercased().contains(text) : user.lowercased().contains(text)
		}
		tableView.reloadData()
	}
	
	private func filterContactsByNameOrHandle(searchText: String) {
		deviceContactList = allContacts.filter { contact in
			let text = searchText.lowercased()
			let handle = contact.handle() ?? ""
			let user = contact.named() ?? ""
			
			return user.lowercased().contains(text) ? user.lowercased().contains(text) : handle.lowercased().contains(text)
		}
		tableView.reloadData()
	}
	
	//MARK: UISearchBarDelegate
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if (searchText.isEmpty) {
			twitterFollowingList = allFollowing
			twitterFollowerList = allFollowers
			deviceContactList = allContacts
		} else {
			switch selectedTab {
			case 0:
				filterFollowingsByNameOrHandle(searchText: searchText)
				break
			case 1:
				filterFollowersByNameOrHandle(searchText: searchText)
				break
			case 2:
				filterContactsByNameOrHandle(searchText: searchText)
				break
			default :
				twitterFollowingList = allFollowing
				twitterFollowerList = allFollowers
				deviceContactList = allContacts
				break
			}
		}
		
		tableView.reloadData()
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		twitterFollowingList = allFollowing
		twitterFollowerList = allFollowers
		deviceContactList = allContacts
		searchBar.text = ""
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.resignFirstResponder()
		navigationController?.setNavigationBarHidden(false, animated: true)
		tableView.reloadData()
	}
	
	func finishFetchFollowings() {
		if self.followingNextCursor == self.NO_MORE_RESULTS || self.followingNextCursor == nil {
			self.allFollowing = self.twitterFollowingList
			self.sortFollowingsAsc()
			self.activityIndicator.stopAnimating()
			self.followingNextCursor = self.NO_MORE_RESULTS
			self.tableView.reloadData()
		}
	}
	
	func finishFetchFollowers() {
		if self.followerNextCursor == self.NO_MORE_RESULTS || self.followerNextCursor == nil {
			self.allFollowers = self.twitterFollowerList
			self.sortFollowersAsc()
			self.activityIndicator.stopAnimating()
			self.followerNextCursor = self.NO_MORE_RESULTS
			self.tableView.reloadData()
		}
	}
	
	func fetchFollowings() {
		let lockQueue = DispatchQueue(label: "com.handler.Followings")
		lockQueue.sync() {
			while let cursor = followingNextCursor, cursor != NO_MORE_RESULTS {
				TwitterAPIOperations.getTwitterFriends(cursor) { (users, nextCursor) in
					self.twitterFollowingList.append(contentsOf: users)
					self.followingNextCursor = nextCursor
					self.finishFetchFollowings()
				}
			}
			self.finishFetchFollowings()
		}
	}
	
	func fetchFollowers() {
		let lockQueue = DispatchQueue(label: "com.handler.Followers")
		lockQueue.sync() {
			while let cursor = followerNextCursor, cursor != NO_MORE_RESULTS {
				TwitterAPIOperations.getTwitterFollowers(cursor) { (users, nextCursor) in
					self.twitterFollowerList.append(contentsOf: users)
					self.followerNextCursor = nextCursor
					self.finishFetchFollowers()
				}
			}
			self.finishFetchFollowers()
		}
	}
	
	func fetchMoreFromTwitter() {
		if selectedTab == 0 {
			fetchFollowings()
		} else if selectedTab == 1 {
			fetchFollowers()
		}
	}
	
	func hideAuthorizationHeaderView() {
		UIView.animate(withDuration: 0.5, animations: {
			self.authorizationHeaderView.layer.opacity = 0
		}, completion: { _ in
			self.authorizationHeaderView.isHidden = true
		})
	}
	
	func hideHeaderView() {
		tableHeaderView.frame = CGRect(x: 0, y: 0, width: self.authorizationHeaderView.frame.width, height: 0)
		tableHeaderView.setNeedsLayout()
		tableHeaderView.layoutIfNeeded()
		tableView.reloadData()
	}
	
	func showHeaderView() {
		tableHeaderView.frame = CGRect(x: 0, y: 0, width: self.authorizationHeaderView.frame.width, height: 110)
		tableHeaderView.setNeedsLayout()
		tableHeaderView.layoutIfNeeded()
		tableView.reloadData()
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
				if self.contactSelectionDelegate != nil {
					self.deviceContactList = contacts?.filter() {
							return !($0.handle() ?? "").isEmpty
						} ?? []
				} else {
					self.deviceContactList = contacts ?? []
				}
				self.allContacts = self.deviceContactList
				self.hideHeaderView()
				self.hideAuthorizationHeaderView()
				self.activityIndicator.stopAnimating()
				self.sortContactsAsc()
				self.tableView.reloadData()
		})
	}
	
	//MARK: Prepare for Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowContactCard" {
			if let contactCardVC = segue.destination as? TwitterContactCardViewController {
				if let handle = sender as? String {
					contactCardVC.handle = handle
				}
			}
		}
	}

	// MARK: - UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		switch selectedTab {
		case 0:
			return twitterFollowingList.count
		case 1:
			return twitterFollowerList.count
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
		
		switch selectedTab {
			case 0:
				cell.followButton.setImage(UIImage(named: "Followed_Icon"), for: .normal)
				break
			case 1:
				cell.followButton.setImage(UIImage(named: "Follow_Icon"), for: .normal)
				break
			case 2:
				cell.followButton.setImage(UIImage(named: "contacts_invite_button_icon"), for: .normal)
				break
			default:
				break
		}
		
		// TODO: make follow button to work
		cell.followButton.isHidden = true

		if let url = user.profilePictureURL() {
			cell.profileImageView.kf.setImage(with: url, placeholder: UIImage.randomGhostImage(), options: nil, progressBlock: nil, completionHandler: nil)
		} else {
			cell.profileImageView.image = UIImage.randomGhostImage()
		}

//		if selectedTab < 2 && indexPath.row == activeTabContacts.count - 3 { // near the end of the list, fetch more from twitter
//			fetchMoreFromTwitter()
//		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)

		// FIXME: This method expects a User but we have either TwitterData or APContact
		
		switch selectedTab {
		case 0:
			if let handle = twitterFollowingList[indexPath.row].handle() {
				if let delegate = contactSelectionDelegate {
					delegate.didSelectHandlerUser(handle)
				} else {
					performSegue(withIdentifier: "ShowContactCard", sender: handle)
				}
			}
			break
		case 1:
			if let handle = twitterFollowerList[indexPath.row].handle() {
				if let delegate = contactSelectionDelegate {
					delegate.didSelectHandlerUser(handle)
				} else {
					performSegue(withIdentifier: "ShowContactCard", sender: handle)
				}
			}
			break
		default :
			if let handle = deviceContactList[indexPath.row].handle(), let delegate = contactSelectionDelegate {
				delegate.didSelectHandlerUser(handle)
			}
			break
		}
	}
	
	private func sortContactsAsc() {
		deviceContactList.sort() { contact1, contact2 in
			if let name1 = contact1.named(), let name2 = contact2.named() {
				return name1.lowercased() < name2.lowercased()
			} else {
				return true
			}
		}
	}
	private func sortFollowingsAsc() {
		twitterFollowingList.sort() {
			if let name1 = $0.name, let name2 = $1.name {
				return name1.lowercased() < name2.lowercased()
			} else {
				return false
			}
		}
	}
	private func sortFollowersAsc() {
		twitterFollowerList.sort() {
			if let name1 = $0.name, let name2 = $1.name {
				return name1.lowercased() < name2.lowercased()
			} else {
				return false
			}
		}
	}

	// MARK - Segmented Button Actions and Helpers

	@IBAction func followingButtonTapped(_ sender: AnyObject) {
		selectTab(0)
		hideHeaderView()
	}

	@IBAction func followersButtonTapped(_ sender: AnyObject) {
		selectTab(1)
		hideHeaderView()
		if followerNextCursor == nil {
			activityIndicator.startAnimating()
			TwitterAPIOperations.getTwitterFollowers(nil) { (users, nextCursor) in
				self.twitterFollowerList = users
				self.fetchFollowers()
			}
		}
	}

	@IBAction func deviceButtonTapped(_ sender: AnyObject) {
		if areContactsAuthrorized() {
			authorizationHeaderView.isHidden = true
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
				return twitterFollowingList
			case 1:
				return twitterFollowerList
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
			selectButton(followingButton)
		case 1:
			selectButton(followersButton)
		case 2:
			selectButton(deviceButton)
		default:
			break
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
		let regularImg = url.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil)
		
		return URL(string: regularImg)
	}
	
}
