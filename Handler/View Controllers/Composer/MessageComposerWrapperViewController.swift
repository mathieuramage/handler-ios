//
//  MessageComposerWrapperViewController.swift
//  Handler
//
//  Created by Otávio on 21/02/16.
//  Updated by Cagdas Altinkaya on 03/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class MessageComposerWrapperViewController: UIViewController, AutoCompleteDelegate, MessageComposeTableViewControllerDelegate {

	var messageToReplyTo : Message?
	var draftMessage : Message?

	@IBOutlet weak var autoCompleteContainerView: UIView!
	@IBOutlet weak var autoCompleteTopConstraint: NSLayoutConstraint!

	var messageComposerController : MessageComposeTableViewController?
	var autoCompleteViewController : ContactsAutoCompleteViewController?

	override func viewDidLoad() {
		super.viewDidLoad()
		autoCompleteContainerView.isHidden = true

		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIKeyboardWillShow,
			object: nil, queue: nil,
			using: { notification in

				if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {

					let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)

					self.messageComposerController?.tableView.contentInset = contentInsets
					self.messageComposerController?.tableView.scrollIndicatorInsets = contentInsets

					self.autoCompleteViewController?.tableView.contentInset = contentInsets
					self.autoCompleteViewController?.tableView.scrollIndicatorInsets = contentInsets
				}

		})

		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.UIKeyboardWillHide,
			object: nil, queue: nil,
			using: { notification in

				self.messageComposerController?.tableView.contentInset = UIEdgeInsets.zero
				self.messageComposerController?.tableView.scrollIndicatorInsets = UIEdgeInsets.zero

				self.autoCompleteViewController?.tableView.contentInset = UIEdgeInsets.zero
				self.autoCompleteViewController?.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
		})
	}


	@IBAction func dismiss(_ sender: UIBarButtonItem) {
		self.messageComposerController?.dismiss()
	}

	@IBAction func send(_ sender: UIBarButtonItem) {
		self.messageComposerController?.send()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == "embedComposer" {

			if let composerTableViewController = segue.destination as? MessageComposeTableViewController {
				self.messageComposerController = composerTableViewController
				composerTableViewController.delegate = self
				composerTableViewController.draftMessage = draftMessage
				composerTableViewController.messageToReplyTo = messageToReplyTo
			}
		} else if segue.identifier == "embedAutoComplete" {

			if let autoCompleteViewController = segue.destination as? ContactsAutoCompleteViewController {
				self.autoCompleteViewController = autoCompleteViewController
				autoCompleteViewController.delegate = self
				autoCompleteViewController.view.isHidden = true
			}
		}
	}

	//MARK : MessageComposeTableViewControllerDelegate
	func autoCompleteUserForPrefix(_ prefix : String) {
		autoCompleteContainerView.isHidden = prefix == ""
//		autoCompleteViewController?.autoCompleteUserForPrefix(prefix)
	}

	func setAutoCompleteViewTopInset(_ topInset : CGFloat) {
		autoCompleteTopConstraint.constant = topInset
		self.view.layoutIfNeeded()
	}


	//MARK : AutoCompleteDelegate
	func contactsAutoCompleteDidSelectUser(_ controller: ContactsAutoCompleteViewController, user: ManagedUser) {
		messageComposerController?.contactsAutoCompleteDidSelectUser(user)
	}

}
