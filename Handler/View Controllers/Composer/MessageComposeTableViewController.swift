//
//  MessageComposeTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Updated by Cagdas Altinkaya on 03/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import HandleriOSSDK
import Async
import RichEditorView

class MessageComposeTableViewController: UITableViewController, CLTokenInputViewDelegate, UITextViewDelegate, UITextFieldDelegate, FilePickerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, ContactSelectionDelegate {

	let ConversationMessageCellID = "ConversationMessageTableViewCell"

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

	var _sizingCell: ConversationMessageTableViewCell?
	var sizingCell: ConversationMessageTableViewCell {
		get {
			if _sizingCell == nil {
				_sizingCell = self.tableView.dequeueReusableCellWithIdentifier(ConversationMessageCellID) as? ConversationMessageTableViewCell
			}

			return _sizingCell!
		}
	}

	var addContactToCC = false

	//	var orderedThreadMessages = [LegacyMessage]()
	var conversations = [Conversation]()


	private var internalmessageToReplyTo: Message?
	var messageToReplyTo: Message? {

		set(new){

			// TODO

			//			if new?.managedObjectContext != MailDatabaseManager.sharedInstance.backgroundContext {
			//				self.internalmessageToReplyTo = new?.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext)
			//			}else{
			//				self.internalmessageToReplyTo = new
			//			}
			//
			//			if let allMessages = new?.thread?.messages?.allObjects as? [LegacyMessage] {
			//				orderedThreadMessages = allMessages.sort({ (item1, item2) -> Bool in
			//					if let firstDate = item1.sent_at, let secondDate = item2.sent_at {
			//						return firstDate.compare(secondDate) == NSComparisonResult.OrderedDescending
			//					}
			//					else {
			//						return true
			//					}
			//				})
			//			}
			//			else {
			//				orderedThreadMessages = [LegacyMessage]()
			//			}
			//
			//			tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)

			self.internalmessageToReplyTo = messageToReplyTo
		}

		get {
			return self.internalmessageToReplyTo
		}
	}
	var messageToForward: Message?
	private var internalDraftmessage: Message?
	var draftMessage: Message?
	// TODO
	//		{
	//		set(new){
	//			if new?.managedObjectContext != MailDatabaseManager.sharedInstance.backgroundContext {
	//				self.internalDraftmessage = new?.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext)
	//			}else{
	//				self.internalDraftmessage = new
	//			}
	//		}
	//
	//		get {
	//			return self.internalDraftmessage
	//		}
	//	}

	private var originalRecipients = [String]()
	private var originalRecipientsChanged = false

	private var originalReplySubject : String?
	private var replySubjectChanged : Bool = false

	@IBOutlet weak var tokenView: CLTokenInputView!
	@IBOutlet weak var ccTokenView: CLTokenInputView!

	@IBOutlet weak var addToContactButton: UIButton!
	@IBOutlet weak var addCCContactButton: UIButton!

	@IBOutlet weak var subjectTextField: UITextField!
	@IBOutlet weak var richTextContentView: RichEditorView!

	@IBOutlet weak var attachmentsCell: MessageAttachmentsTableViewCell!

	var validatedTokens = [ValidatedToken]()

	var activeTokenField: CLTokenInputView?
	var keyboardFirstTime: Bool = true

	var delegate : MessageComposeTableViewControllerDelegate?

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let messageNib = UINib(nibName: "ConversationMessageTableViewCell", bundle: nil);
		tableView.registerNib(messageNib, forCellReuseIdentifier: ConversationMessageCellID)
		tableView.tableFooterView = UIView()

		subjectTextField.delegate = self


		// UI Configuration
		self.richTextContentView.setPlaceholderText("Share something")
		self.richTextContentView.setTextColor(UIColor(rgba: HexCodes.lightGray))
		self.richTextContentView.delegate = self
		self.richTextContentView.webView.dataDetectorTypes = [.All]
		self.richTextContentView.webView.backgroundColor = UIColor.clearColor()
		self.richTextContentView.webView.scrollView.backgroundColor = UIColor.clearColor()
		self.richTextContentView.backgroundColor = UIColor.clearColor()
		self.richTextContentView.webView.opaque = false
		//		if let draft = draftMessage {
		//
		//
		//				for recipient in draft.recipients {
		//					if let handle = recipient.handle {
		//						tokenView.addToken(CLToken(displayText: "@\(handle)", context: nil))
		//						startValidationWithString("@\(handle)")
		//					}
		//				}
		//
		//
		//			self.subjectTextField.text = draft.subject
		//			self.richTextContentView.setHTML(draft.message ?? "")
		////			attachmentsCell.attachments = draft.attachments?.allObjects as? [Attachment]
		//
		//		}else{

		if let message = messageToReplyTo where message.sender!.handle.characters.count > 0 {
			let sender = message.sender!.handle
			self.title = "New Reply"
			validatedTokens.append(ValidatedToken(name: sender, isOnHandler: true))

			tokenView.addToken(CLToken(displayText: "@\(sender)", context: nil))
			tokenView.validatedString(sender, withResult: true)
			tokenView.reloadTokenWithTitle(sender)

			if message.hasReplyPrefix() {
				subjectTextField.text = message.subject
			}
			else {
				subjectTextField.text = "\(message.replyPrefix) \(message.subject ?? "")"
			}

			originalReplySubject = subjectTextField.text
		}

		if let receivers = messageToReplyTo?.recipientsWithoutSelf(){
			for receiver in receivers {
				let senderUsername = receiver.handle
				if senderUsername.characters.count > 0 {
					validatedTokens.append(ValidatedToken(name: senderUsername, isOnHandler: true))
					ccTokenView.addToken(CLToken(displayText: "@\(senderUsername)", context: nil))
					ccTokenView.validatedString(senderUsername, withResult: true)
					ccTokenView.reloadTokenWithTitle(senderUsername)
				}
			}
			//			}

			originalRecipients = validatedTokens.map( { $0.name } )
			//			if let msg = messageToForward {
			//				attachmentsCell.attachments = msg.attachments?.allObjects as? [Attachment]
			//			}
		}

		//		attachmentsCell.filePresentingVC = self
		//		attachmentsCell.reloadClosure = {[unowned self] ()->Void in
		//			self.tableView.beginUpdates()
		//			self.tableView.endUpdates()
		//		}
		//		attachmentsCell.filePickerDelegate = self

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		enableSendButton()
	}

	// MARK: Contacts Add Buttons

	@IBAction func contactButtonPressed(button: UIButton){
		if button == self.addToContactButton {
			// Add recipient
			addContactToCC = false
		} else {
			// Add CC
			addContactToCC = true
		}

		performSegueWithIdentifier("showContacts", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showContacts" {
			let destinationVC = segue.destinationViewController as! ContactsTableViewController
			destinationVC.userSelectionDelegate = self
		}
	}

	func didSelectUser(user: ManagedUser) {
		navigationController?.popViewControllerAnimated(true)
		validatedTokens.append(ValidatedToken(name: user.handle ?? "", isOnHandler: true))
		if addContactToCC {
			self.ccTokenView.addToken(CLToken(displayText: "@" + (user.handle ?? ""), context: nil))
		}else{
			self.tokenView.addToken(CLToken(displayText: "@" + (user.handle ?? ""), context: nil))
		}
	}
	// MARK: Sending / Cancelling

	func dismiss() {

		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

		alertController.addAction(UIAlertAction(title: "Delete Draft", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
			if let attachments = self.attachmentsCell.attachments {
				for attachment in attachments {
					attachment.delete()
				}
			}
			self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		}))


		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in

		}))

		presentViewController(alertController, animated: true, completion: nil)

		// Draft disabled for now as per IOS-96

		//        if let draft = draftMessage {
		//            self.updateDraftFromUI(draft: draft).saveAsDraft()
		//            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		//        }else{
		//            let alertController = UIAlertController(title: "Save as draft", message: "Do you want to save this message as a draft?", preferredStyle: UIAlertControllerStyle.Alert)
		//            alertController.addAction(UIAlertAction(title: "Save as Draft", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
		//                self.createMessageFromUI().saveAsDraft()
		//                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		//            }))
		//            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
		//                if let attachments = self.attachmentsCell.attachments {
		//                    for attachment in attachments {
		//                        attachment.delete()
		//                    }
		//                }
		//                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		//            }))
		//            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		//            presentViewController(alertController, animated: true, completion: nil)
		//        }
	}

	func send() {

		switchUserInteractionState(false)

		let message = richTextContentView.contentHTML
		let subject = subjectTextField.text ?? ""

		var recipients = [String]()
		for token in tokenView.allTokens {
//			for validtoken in validatedTokens {
//				if validtoken.isOnHandler && validtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
//					recipients.append(validtoken.name)
//				}
//			}

			recipients.append(token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""))  //FIXME, temporary IMPORTANT, DELETE THIS and uncomment above.
		}

		guard recipients.count > 0 else {
			var errorPopup = ErrorPopupViewController()
			errorPopup.displayMessageLabel.text = "You need at least one receiver and a subject / content"
			errorPopup.show()
			switchUserInteractionState(true)
			return
		}


		guard message.characters.count > 0 || subject.characters.count > 0 else {
			var errorPopup = ErrorPopupViewController()
			errorPopup.displayMessageLabel.text = "You need at least one receiver and a subject / content"
			errorPopup.show()
			switchUserInteractionState(true)
			return
		}


		if (subject.characters.count == 0) {

			let alertController = UIAlertController(title: "Empty subject", message: "This message has no subject line.\n Do you want to send it anyway?", preferredStyle: .Alert)

			let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
				self.switchUserInteractionState(true)
			}

			let sendAnywayAction = UIAlertAction(title: "Send", style: .Default) { (action) in

				if let replyTo = self.messageToReplyTo {
					MessageOperations.replyToUserNames(recipients, conversationId: replyTo.conversationId!, message: message, subject: subject, callback: { (success) in
						// TODO?
					})
				} else {

					MessageOperations.sendNewMessage(message, subject: subject, recipientUserNames: recipients, callback: { (success) in
						// TODO?
					})
				}

				self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
				self.switchUserInteractionState(true)
			}

			alertController.addAction(cancelAction)
			alertController.addAction(sendAnywayAction)

			self.presentViewController(alertController, animated: true, completion: nil)

		} else {


			if let replyTo = self.messageToReplyTo {
				MessageOperations.replyToUserNames(recipients, conversationId: replyTo.conversationId!, message: message, subject: subject, callback: { (success) in
					// TODO?
				})
			} else {

				MessageOperations.sendNewMessage(message, subject: subject, recipientUserNames: recipients, callback: { (success) in
					// TODO?
				})
			}


		}

	}

	func updateDraftFromUI(draft draft: ManagedMessage) -> ManagedMessage {
		configMsg(draft)
		return draft
	}

	//	func createMessageFromUI() -> MessageData {
	////		let message = LegacyMessage(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
	//
	//		let message = MessageData()
	//
	//		var receivers = [User]()
	//		for token in tokenView.allTokens {
	//			for valdtoken in validatedTokens {
	//				if valdtoken.isOnHandler && valdtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
	//					receivers.append(LegacyUser.fromHandle(valdtoken.name))
	//				}
	//			}
	//		}
	//
	////		var attachments = [Attachment]()
	////		for attachment in attachmentsCell.attachments ?? [Attachment]() {
	////			if let converted = attachment.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
	////				attachments.append(converted)
	////			}
	////		}
	//
	////		message.attachments = NSSet(array: attachments)
	//		message.recipients = receivers
	//		message.message = richTextContentView.contentHTML
	//		message.subject = subjectTextField.text ?? ""
	//
	//		return message
	//	}

	func configMsg(message: ManagedMessage) -> ManagedMessage {

		var receivers = [ManagedUser]()
		for token in tokenView.allTokens {
			for valdtoken in validatedTokens {
				if valdtoken.isOnHandler && valdtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
					receivers.append(ManagedUser.userWithHandle(valdtoken.name, inContext: DatabaseManager.sharedInstance.mainManagedContext))
				}
			}
		}

		var attachments = [Attachment]()
		for attachment in attachmentsCell.attachments ?? [Attachment]() {
			if let converted = attachment.toManageObjectContext(DatabaseManager.sharedInstance.backgroundContext) {
				attachments.append(converted)
			}
		}

		message.recipients = NSSet(array: receivers)
		message.content = richTextContentView.contentHTML
		message.subject = subjectTextField.text ?? ""
		return message
	}

	// MARK: UI Utils

	func switchUserInteractionState(enabled: Bool){
		if !enabled {
			resignAll()
		}
		subjectTextField.enabled = enabled
		richTextContentView.userInteractionEnabled = enabled
		tokenView.userInteractionEnabled = enabled
		ccTokenView.userInteractionEnabled = enabled
	}

	func resignAll(){
		subjectTextField.resignFirstResponder()
		richTextContentView.resignFirstResponder()
		tokenView.resignFirstResponder()
		ccTokenView.resignFirstResponder()
	}

	func textViewDidChange(textView: UITextView) {
		tableView.beginUpdates()
		tableView.endUpdates()
	}

	// MARK: TokenViewDelegate

	func tokenInputView(view: CLTokenInputView, didChangeText text: String?) {
		guard let text = text else {
			return
		}

		let escapedString = text.stringByReplacingOccurrencesOfString("@", withString: "")

		delegate?.autoCompleteUserForPrefix(escapedString)
	}

	func textColorForTokenViewWithToken(token: CLToken) -> UIColor {
		guard token.displayText.lowercaseString.stringByReplacingOccurrencesOfString("@", withString: "") != "" else {
			return UIColor(rgba: HexCodes.darkGray)
		}
		for validatedToken in validatedTokens {
			if validatedToken.name != "" && validatedToken.name.lowercaseString == token.displayText.lowercaseString.stringByReplacingOccurrencesOfString("@", withString: "") && validatedToken.isOnHandler {
				return UIColor(rgba: HexCodes.lightBlue)
			}
		}
		return UIColor(rgba: HexCodes.darkGray)
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

		activeTokenField = view

		if let frame = activeTokenField!.superview?.convertRect(activeTokenField!.frame, toView: nil) {
			let tableY = self.tableView.superview!.convertRect(self.tableView.frame, toView: nil).origin.y
			let insetTop = frame.origin.y + frame.size.height - tableY + 15 // 15 to accomodate for bottom spacing in cells
			self.delegate?.setAutoCompleteViewTopInset(insetTop)
		}
	}

	func tokenInputViewDidEndEditing(view: CLTokenInputView) {
		if view == tokenView {
			addToContactButton.hidden = true
		}else{
			addCCContactButton.hidden = true
		}

		activeTokenField = nil
	}

	func tokenView(view: CLTokenView, didSelectToken token: CLToken) {
		view.resignFirstResponder()
		ContactCardViewController.showWithHandle(token.displayText.lowercaseString.stringByReplacingOccurrencesOfString("@", withString: ""))
	}

	func tokenView(view: CLTokenView, didUnselectToken token: CLToken) {

	}

	// Fix a bug where more than one token where being deleted with backspace
	func tokenInputView(view: CLTokenInputView, didAddToken token: CLToken) {
		view.endEditing()
		view.beginEditing()

		enableSendButton()
	}


	func tokenInputView(view: CLTokenInputView, didRemoveToken token: CLToken) {
		// Fix a bug where more than one token where being deleted with backspace
		view.endEditing()
		view.beginEditing()

		if shouldShowAlertForOriginalRecipientChange(token) {
			let alertController = UIAlertController(title: "New thread", message: "Removing someone from a thread will create a new, seperate thread.", preferredStyle: UIAlertControllerStyle.Alert)

			alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				view.addToken(token)
			}))

			alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				self.originalRecipientsChanged = true
				self.messageToReplyTo = nil
			}))

			presentViewController(alertController, animated: true, completion: nil)
		}

		enableSendButton()
	}

	func shouldShowAlertForOriginalRecipientChange(token: CLToken) -> Bool {
		if originalRecipientsChanged || messageToReplyTo == nil {
			return false
		}

		let escapedToken = token.displayText.stringByReplacingOccurrencesOfString("@", withString: "")

		if escapedToken == "" {
			return false
		}

		if !originalRecipients.contains(escapedToken) {
			return false
		}

		// Handle a case where the user added an original recipient to the list so it appears more than one time
		for typedToken in (tokenView.allTokens + ccTokenView.allTokens) {
			if typedToken.displayText == token.displayText {
				return false
			}
		}

		return true
	}

	func startValidationWithString(string: String) {
		guard string.stringByReplacingOccurrencesOfString("@", withString: "") != "" else {
			return
		}

		for validatedToken in validatedTokens {
			if validatedToken.name.lowercaseString == string.stringByReplacingOccurrencesOfString("@", withString: "") {
				return
			}
		}

		// TODO: implement using the new API
//		APICommunicator.sharedInstance.checkUserWithCallback(string.stringByReplacingOccurrencesOfString("@", withString: "")) { (user, error) in
//			guard let user = user else {
//				self.validatedTokens.append(ValidatedToken(name: string.stringByReplacingOccurrencesOfString("@", withString: ""), isOnHandler: false))
//				self.tokenView.validatedString(string, withResult: false)
//				self.ccTokenView.validatedString(string, withResult: false)
//				return
//			}
//			self.validatedTokens.append(ValidatedToken(name: string.stringByReplacingOccurrencesOfString("@", withString: ""), isOnHandler: true, user: user))
//			self.tokenView.validatedString(user.handle, withResult: true)
//			self.tokenView.reloadTokenWithTitle(user.handle)
//			self.ccTokenView.validatedString(user.handle, withResult: true)
//			self.ccTokenView.reloadTokenWithTitle(user.handle)
//		}
	}

	// MARK: TableViewDelegate & DataSource

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return super.tableView(tableView, numberOfRowsInSection: section)
		}

		return conversations.count
	}

	override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
		return 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
		}

		let cell = tableView.dequeueReusableCellWithIdentifier(ConversationMessageCellID, forIndexPath: indexPath) as! ConversationMessageTableViewCell

		configureThreadMessageCell(cell, indexPath: indexPath)

		return cell
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}

	override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return UITableViewAutomaticDimension
		}

		// Using UITableViewAutomaticDimension was producing lots of autolayout warnings due the auto added constraint for the Height
		configureThreadMessageCell(sizingCell, indexPath: indexPath)

		return sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			if indexPath.row == 2 {
				return max(CGFloat(richTextContentView.editorHeight + 40), CGFloat(300))
			} else if indexPath.row == 4 {
				if FeaturesManager.attachmentsActivated {
					return max(attachmentsCell.intrinsicContentSize().height + 20, 50+20)
				}else{
					return 0
				}
			}

			return UITableViewAutomaticDimension
		}

		configureThreadMessageCell(sizingCell, indexPath: indexPath)

		return sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
	}

	// MARK: FilePickerDelegate

	func presentFilePicker() {
		let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data","public.content"], inMode: UIDocumentPickerMode.Open)
		docPicker.delegate = self
		Async.main(after: 0.1) { () -> Void in
			self.presentViewController(docPicker, animated: true, completion: nil)
		}
	}

	func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
		Async.background { () -> Void in
			if url.startAccessingSecurityScopedResource() {
				let coordinator = NSFileCoordinator()
				coordinator.coordinateReadingItemAtURL(url, options: NSFileCoordinatorReadingOptions.ResolvesSymbolicLink, error: nil, byAccessor: { (url) -> Void in
					if let data = NSData(contentsOfURL: url){
						self.saveFileToAttachment(data, url: url)
					}else{
						print("Unable to read file at url: \(url)")
					}
				})

				url.stopAccessingSecurityScopedResource()
			}else{
				print("Couldn't enter security scope")
			}
		}
	}

		func saveFileToAttachment(file: NSData, url: NSURL){
			guard let filetype = url.pathExtension else {
				print("\(url) had no filtype")
				return
			}
			guard let originalFileName = url.lastPathComponent else {
				print("\(url) had no filename")
				return
			}
			guard let docsDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).first else {
				print("caches directory not found")
				return
			}
			var docsDirURL = NSURL(fileURLWithPath: docsDir, isDirectory: true)
			let filename = NSUUID().UUIDString.stringByAppendingString("."+filetype)
			docsDirURL = docsDirURL.URLByAppendingPathComponent(filename)
			DatabaseManager.sharedInstance.backgroundContext.performBlock { () -> Void in
	
				if file.writeToURL(docsDirURL, atomically: true) {
	
					let attachment = Attachment(localFile: docsDirURL, filename: originalFileName)
					DatabaseManager.sharedInstance.mainManagedContext.saveRecursively()
					Async.main(block: { () -> Void in
						self.attachmentsCell.attachments?.append(attachment)
					})
				}else{
					print("Failed to write file")
				}
			}
	
		}

	func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
		return self.navigationController ?? self
	}

	// Mark: ContactsAutoCompleteViewControllerDelegateDelegate

	func contactsAutoCompleteDidSelectUser(user: ManagedUser) {
		let handle = user.handle

		guard handle.characters.count > 0 else {
			return
		}

		validatedTokens.append(ValidatedToken(name: handle, isOnHandler: true))

		let token = CLToken(displayText: "@\(handle)", context: nil)
		if self.tokenView.editing {
			self.tokenView.addToken(token)

		}
		else if self.ccTokenView.editing {
			self.ccTokenView.addToken(token)
		}
	}


	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

		if (textField == subjectTextField && internalmessageToReplyTo != nil) {

			if (replySubjectChanged) { // already changed subject
				return true
			}

			if (string != originalReplySubject) {

				let alertController = UIAlertController(title: "New Thread", message: "Changing the subject line of a thread will create a new, separate thread.", preferredStyle: UIAlertControllerStyle.Alert)

				alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
				}))

				alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
					self.replySubjectChanged = true
					self.messageToReplyTo = nil
				}))

				presentViewController(alertController, animated: true, completion: nil)
			}
			return false
		}

		return true

	}

	func configureThreadMessageCell(cell: ConversationMessageTableViewCell, indexPath: NSIndexPath) {
		let message = conversations[indexPath.row]

		let lastMessage = indexPath.row + 1 >= conversations.count
		//		let primary = message == orderedThreadMessages // What?
		let primary = false // TODO
		//		ConversationTableViewCellHelper.configureCell(cell, message: message, lastMessage: lastMessage, primary: primary)
	}

	// MARK: UITextViewDelegate
	func textViewDidBeginEditing(textView: UITextView) {
		if textView.textColor == UIColor(rgba: HexCodes.lightGray) {
			textView.text = nil
			textView.textColor = UIColor(rgba: HexCodes.darkGray)
		}
	}

	func enableSendButton() {

		guard let navC = self.navigationController else {
			return
		}
		guard let messageComposerWrapperViewController = navC.topViewController as? MessageComposerWrapperViewController else {
			return
		}

		guard let sendButton = messageComposerWrapperViewController.navigationItem.rightBarButtonItem  else {
			return
		}
		
		sendButton.enabled = !self.tokenView.allTokens.isEmpty
	}
}


protocol MessageComposeTableViewControllerDelegate {
	func autoCompleteUserForPrefix(prefix : String)
	func setAutoCompleteViewTopInset(topInset: CGFloat)
}

extension MessageComposeTableViewController: RichEditorDelegate {
	
	func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool {
		return false
	}
}
