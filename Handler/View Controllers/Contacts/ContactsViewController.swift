//
//  ContactsViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 22/4/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var searchBar: UISearchBar!

	@IBOutlet weak var followersButton: UIButton!
	@IBOutlet weak var followingButton: UIButton!
	@IBOutlet weak var deviceButton: UIButton!
	@IBOutlet weak var borderView: UIView!

	var twitterFollowerList: [TwitterUserData] = []
	var twitterFollowingList : [TwitterUserData] = []
	var deviceContactList : [User] = []

	let addressBook = APAddressBook()

	var followerNextCursor : Int?
	var followingNextCursor : Int?

	var selectedTab : Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		selectTab(0)
        selectButton(self.followersButton)
		borderView.layer.cornerRadius = 5
		borderView.clipsToBounds = true
		borderView.layer.borderWidth = 1
		borderView.layer.borderColor = borderView.tintColor.cgColor
		searchBar.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

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
	}

	func fetchMoreFromTwitter() {
		if selectedTab == 0 {
			if let cursor = followerNextCursor {
				TwitterAPIOperations.getTwitterFollowers(cursor) { (users, nextCursor) in
					self.twitterFollowerList.append(users)
					self.followerNextCursor = nextCursor
					self.tableView.reloadData()
				}
			}

		} else if selectedTab == 1 {

			if let cursor = followingNextCursor {
				TwitterAPIOperations.getTwitterFriends(cursor) { (users, nextCursor) in
					self.twitterFollowingList.append(users)
					self.followingNextCursor = nextCursor
					self.tableView.reloadData()
				}
			}

		}
	}

	func setupDeviceContacts() {
		self.addressBook.fieldsMask = [APContactField.default, APContactField.thumbnail, APContactField.websites]
		self.addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
		                                    NSSortDescriptor(key: "name.lastName", ascending: true)]
		self.addressBook.filterBlock = {
			(contact: APContact) -> Bool in
			if let websites = contact.websites {
				for website in websites {
					if let handle = self.extractTwitterHandle(website), handle.characters.count > 0 {
						return true
					}
				}
			}
			return false
		}
		self.addressBook.startObserveChanges(callback: {
			[unowned self] in
			self.fetchDeviceContactList()
			})
	}

	func fetchDeviceContactList() {
//		self.addressBook.loadContacts({
//			(contacts: [APContact]?, error: NSError?) in
//			self.deviceContactList = []
//			if let contacts = contacts {
//				for contact in contacts {
//
//					var handle : String?
//					for website in contact.websites! {
//						handle = self.extractTwitterHandle(website)
//						if let handle = handle, handle.characters.count > 0 {
//                            if let user = UserDao.findUserWithHandle(handle) {
//                            
//							user.name = contact.name?.compositeName
//							self.deviceContactList.append(user)
//						}
//					}
//				}
//
//			}
//			self.tableView.reloadData()
//		}
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

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "contactTableViewCell", for: indexPath) as! ContactTableViewCell
		cell.profileImageView.image = UIImage.randomGhostImage()

		// OTTODO: Reimplement this
//		let user : User = activeTabContacts[indexPath.row]
//
//		cell.handleLabel.text = user.handle
//		cell.nameLabel.text = user.name
//
//		if let urlStr = user.profile_picture_url, let url = NSURL(string : urlStr) {
//			cell.profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage.randomGhostImage())
//		} else {
//			cell.profileImageView.image = UIImage.randomGhostImage()
//		}
//
//		if indexPath.row == activeTabContacts.count - 3 && selectedTab < 2 { // near the end of the list, fetch more from twitter
//			fetchMoreFromTwitter()
//		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
//		let user : LegacyUser = activeTabContacts[indexPath.row]
//		ContactCardViewController.showWithUser(user)
	}



	// MARK - Segmented Button Actions and Helpers

	@IBAction func followersButtonTapped(_ sender: AnyObject) {
		selectTab(0)
	}

	@IBAction func followingButtonTapped(_ sender: AnyObject) {
		selectTab(1)
	}

	@IBAction func deviceButtonTapped(_ sender: AnyObject) {
		selectTab(2)
		if self.deviceContactList.isEmpty {
			setupDeviceContacts()
			fetchDeviceContactList()
		}
	}

	// OTTODO: Reimplement this
//	var activeTabContacts : [TwitterUser] {
//		get {
//			switch selectedTab {
//			case 0:
//				return twitterFollowerList
//			case 1:
//				return twitterFollowingList
//			case 2:
//				return deviceContactList
//			default :
//				return [] // Should never reach here
//			}
//		}
//	}

	func selectTab(_ index : Int) {

		if selectedTab == index {
			return
		}
		resetButtons()
		selectedTab = index

		switch index {
		case 0:
			selectButton(followersButton)
			break
		case 1:
			selectButton(followingButton)
			break
		case 2:
			selectButton(deviceButton)
			break
		default:
			break
		}
		tableView.setContentOffset(CGPoint.zero, animated:false)

		// OTTODO: Reimplement this
//		if (activeTabContacts.count > 0) {
//			activityIndicator.stopAnimating()
//		}
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
		followersButton.backgroundColor = view.backgroundColor
		followingButton.backgroundColor = view.backgroundColor
		deviceButton.backgroundColor = view.backgroundColor
	}

	// MARK - Contact Twitter

	func extractTwitterHandle(_ url : String) -> String? {

		let regex = try! NSRegularExpression(pattern: "^http(s)?://(www.)?twitter.com/", options: [.caseInsensitive])
		let range = NSMakeRange(0, url.characters.count)
		if let _ = regex.firstMatch(in: url, options: [], range: range ) {
			return regex.stringByReplacingMatches(in: url, options: [], range: range, withTemplate: "")
		}
		return nil
	}
	
}
