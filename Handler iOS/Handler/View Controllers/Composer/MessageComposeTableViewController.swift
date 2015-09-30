//
//  MessageComposeTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK

class MessageComposeTableViewController: UITableViewController, CLTokenInputViewDelegate, UITextViewDelegate {
	
	struct ValidatedToken {
		var name: String
		var isOnHandler: Bool
		var user: HRUser?
		
		init(name: String, isOnHandler: Bool, user: HRUser? = nil){
			self.name = name
			self.isOnHandler = isOnHandler
			self.user = user
		}
	}
	
	var messageToReplyTo: Message?
	var messageToForward: Message?
	
	@IBOutlet weak var tokenView: CLTokenInputView!
	@IBOutlet weak var ccTokenView: CLTokenInputView!
	
	@IBOutlet weak var addToContactButton: UIButton!
	@IBOutlet weak var addCCContactButton: UIButton!
	
	@IBOutlet weak var subjectTextField: UITextField!
	@IBOutlet weak var contentTextView: UITextView!
	
	var validatedTokens = [ValidatedToken]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tokenView.tintColor = UIColor.hrLightGrayColor()
		ccTokenView.tintColor = UIColor.hrLightGrayColor()
		if let message = messageToReplyTo, let sender = message.sender?.handle {
			tokenView.addToken(CLToken(displayText: "@\(sender)", context: nil))
			startValidationWithString("@\(sender)")
			if let subject = message.subject {
				subjectTextField.text = "RE: \(subject)"
			}
		}
		if let receivers = messageToReplyTo?.recipientsWithoutSelf(), let all = receivers.allObjects as? [User] {
			for receiver in all {
				ccTokenView.addToken(CLToken(displayText: "@\(receiver.handle!)", context: nil))
				startValidationWithString("@\(receiver.handle!)")
			}
		}
	}
	
	@IBAction func dismiss(sender: UIBarButtonItem) {
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func send(sender: UIBarButtonItem) {
		switchUserInteractionState(false, sender: sender)
		
		let message = HRMessage()
		var receivers = [HRUser]()
		for token in tokenView.allTokens {
			for valdtoken in validatedTokens {
				if valdtoken.isOnHandler && valdtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
					let user = HRUser()
					user.handle = valdtoken.name
					receivers.append(user)
				}
			}
		}
		
		message.recipients = receivers
		message.content = contentTextView.text
		message.subject = subjectTextField.text ?? ""
		
		if receivers.count == 0 || contentTextView.text == "" || subjectTextField.text == "" {
			var errorPopup = ErrorPopupViewController()
			errorPopup.displayMessageLabel.text = "You need at least one receiver and a subject / content"
			errorPopup.show()
			switchUserInteractionState(true, sender: sender)
			return
		}
		
		if let messageReplyTo = messageToReplyTo {
			HandlerAPI.replyToMessageWithID(messageReplyTo.id!, reply: message, callback: { (message, error) -> Void in
				self.switchUserInteractionState(true, sender: sender)

				guard let message = message else {
					if let error = error {
						var errorPopup = ErrorPopupViewController()
						errorPopup.error = error
						errorPopup.show()
					}
					return
				}
				MailDatabaseManager.sharedInstance.storeMessage(message)
				self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
			})
		}else{
			
			HandlerAPI.sendMessage(message) { (message, error) -> Void in
				self.switchUserInteractionState(true, sender: sender)
				guard let message = message else {
					if let error = error {
						var errorPopup = ErrorPopupViewController()
						errorPopup.error = error
						errorPopup.show()
					}
					return
				}
				MailDatabaseManager.sharedInstance.storeMessage(message)
				self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}
	
	func switchUserInteractionState(enabled: Bool, sender: UIBarButtonItem? = nil){
		sender?.enabled = enabled
		subjectTextField.enabled = enabled
		contentTextView.userInteractionEnabled = enabled
		tokenView.userInteractionEnabled = enabled
		ccTokenView.userInteractionEnabled = enabled
	}
	
	func textViewDidChange(textView: UITextView) {
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	// MARK: TokenViewDelegate
	
	func textColorForTokenViewWithToken(token: CLToken) -> UIColor {
		guard token.displayText.stringByReplacingOccurrencesOfString("@", withString: "") != "" else {
			return UIColor.hrLightGrayColor()
		}
		for validatedToken in validatedTokens {
			if validatedToken.name != "" && validatedToken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: "") && validatedToken.isOnHandler {
				return UIColor.hrBlueColor()
			}
		}
		return UIColor.hrLightGrayColor()
	}
	
	func tokenInputView(view: CLTokenInputView, didChangeHeightTo height: CGFloat) {
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func tokenInputView(view: CLTokenInputView, tokenForText text: String) -> CLToken? {
		return CLToken(displayText: text, context: nil)
	}
	
	func tokenInputViewDidBeginEditing(view: CLTokenInputView) {
		if view == tokenView {
			addToContactButton.hidden = false
		}else{
			addCCContactButton.hidden = false
		}
	}
	
	func tokenInputViewDidEndEditing(view: CLTokenInputView) {
		if view == tokenView {
			addToContactButton.hidden = true
		}else{
			addCCContactButton.hidden = true
		}
	}
	
	func startValidationWithString(string: String) {
		guard string.stringByReplacingOccurrencesOfString("@", withString: "") != "" else {
			return
		}
		
		for validatedToken in validatedTokens {
			if validatedToken.name == string.stringByReplacingOccurrencesOfString("@", withString: "") {
				return
			}
		}
		HandlerAPI.checkUserWithCallback(string.stringByReplacingOccurrencesOfString("@", withString: "")) { (user, error) in
			guard let user = user else {
				self.validatedTokens.append(ValidatedToken(name: string.stringByReplacingOccurrencesOfString("@", withString: ""), isOnHandler: false))
				self.tokenView.validatedString(string, withResult: false)
				self.ccTokenView.validatedString(string, withResult: false)
				print(error)
				return
			}
			self.validatedTokens.append(ValidatedToken(name: string.stringByReplacingOccurrencesOfString("@", withString: ""), isOnHandler: true, user: user))
			self.tokenView.validatedString(string, withResult: true)
			self.tokenView.reloadTokenWithTitle(string)
			self.ccTokenView.validatedString(string, withResult: true)
			self.ccTokenView.reloadTokenWithTitle(string)
		}
	}
	
	// MARK: TableViewDelegate
	
	override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row == 3 {
			return max(CGFloat(contentTextView.contentSize.height + 40), CGFloat(300))
		}
		return UITableViewAutomaticDimension
	}
}
