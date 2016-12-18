//
//  MessageComposeTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Updated by Cagdas Altinkaya on 03/03/16.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Async
import RichEditorView

class MessageComposeTableViewController: UITableViewController, CLTokenInputViewDelegate, UITextViewDelegate, UITextFieldDelegate, FilePickerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, ContactSelectionDelegate {
    
    let ConversationMessageCellID = "ConversationMessageTableViewCell"
    
    struct ValidatedToken {
        var name: String
        var isOnHandler: Bool
        //		var user: HRUser?
        
        //		init(name: String, isOnHandler: Bool, user: HRUser? = nil){
        //			self.name = name
        //			self.isOnHandler = isOnHandler
        //			self.user = user
        //		}
    }
    
    var _sizingCell: ConversationMessageTableViewCell?
    var sizingCell: ConversationMessageTableViewCell {
        get {
            if _sizingCell == nil {
                _sizingCell = self.tableView.dequeueReusableCell(withIdentifier: ConversationMessageCellID) as? ConversationMessageTableViewCell
            }
            
            return _sizingCell!
        }
    }
    
    var addContactToCC = false
    
    //	var orderedThreadMessages = [LegacyMessage]()
    var conversations = [Conversation]()
    
    
    fileprivate var internalmessageToReplyTo: Message?
    var messageToReplyTo: Message? {
        
        set(new){
            
            // TODO
            
            //			if new?.managedObjectContext != MailDatabaseManager.sharedInstance.backgroundContext {
            //				self.internalmessageToReplyTo = new?.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext)
            //			} else {
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
    fileprivate var internalDraftmessage: Message?
    var draftMessage: Message?
    // TODO
    //		{
    //		set(new){
    //			if new?.managedObjectContext != MailDatabaseManager.sharedInstance.backgroundContext {
    //				self.internalDraftmessage = new?.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext)
    //			} else {
    //				self.internalDraftmessage = new
    //			}
    //		}
    //
    //		get {
    //			return self.internalDraftmessage
    //		}
    //	}
    
    fileprivate var originalRecipients = [String]()
    fileprivate var originalRecipientsChanged = false
    
    fileprivate var originalReplySubject : String?
    fileprivate var replySubjectChanged : Bool = false
    
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messageNib = UINib(nibName: "ConversationMessageTableViewCell", bundle: nil);
        tableView.register(messageNib, forCellReuseIdentifier: ConversationMessageCellID)
        tableView.tableFooterView = UIView()
        
        subjectTextField.delegate = self
        
        
        // UI Configuration
        self.richTextContentView.setPlaceholder(text: "Share something")
        self.richTextContentView.setText(color: UIColor(rgba: HexCodes.lightGray))
        self.richTextContentView.delegate = self
        self.richTextContentView.webView.dataDetectorTypes = [.all]
        self.richTextContentView.webView.backgroundColor = UIColor.clear
        self.richTextContentView.webView.scrollView.backgroundColor = UIColor.clear
        self.richTextContentView.backgroundColor = UIColor.clear
        self.richTextContentView.webView.isOpaque = false
        if let draft = draftMessage {
            if let recipients = draft.recipients {
                for recipient in recipients {
                    let handle = (recipient as! ManagedUser).handle
                    tokenView.add(CLToken(displayText: "@\(handle)", context: nil))
                    //// startValidationWithString("@\(handle)")
                }
            }
            subjectTextField.text = draft.subject
            richTextContentView.set(html: draft.content ?? "")
            
        } else if let message = messageToReplyTo, message.sender!.handle.characters.count > 0 {
            let sender = message.sender!.handle
            self.title = "New Reply"
            validatedTokens.append(ValidatedToken(name: sender, isOnHandler: true))
            
            tokenView.add(CLToken(displayText: "@\(sender)", context: nil))
            tokenView.validatedString(sender, withResult: true)
            tokenView.reloadToken(withTitle: sender)
            
            if message.hasReplyPrefix() {
                subjectTextField.text = message.subject
            }
            else {
                subjectTextField.text = "\(message.replyPrefix) \(message.subject ?? "")"
            }
            
            originalReplySubject = subjectTextField.text
        }
        
        if let receivers = messageToReplyTo?.recipientsWithoutSelf() {
            for receiver in receivers {
                let senderUsername = (receiver as? ManagedUser)?.handle
                if (senderUsername?.characters.count)! > 0 {
                    validatedTokens.append(ValidatedToken(name: senderUsername!, isOnHandler: true))
                    ccTokenView.add(CLToken(displayText: "@\(senderUsername)", context: nil))
                    ccTokenView.validatedString(senderUsername!, withResult: true)
                    ccTokenView.reloadToken(withTitle: senderUsername!)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableSendButton()
    }
    
    // MARK: Contacts Add Buttons
    
    @IBAction func contactButtonPressed(_ button: UIButton){
        if button == self.addToContactButton {
            // Add recipient
            addContactToCC = false
        } else {
            // Add CC
            addContactToCC = true
        }
        
        performSegue(withIdentifier: "showContacts", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContacts" {
            let destinationVC = segue.destination as! ContactsTableViewController
            destinationVC.userSelectionDelegate = self
        }
    }
    
    func didSelectUser(_ user: ManagedUser) {
        navigationController?.popViewController(animated: true)
        validatedTokens.append(ValidatedToken(name: user.handle ?? "", isOnHandler: true))
        if addContactToCC {
            self.ccTokenView.add(CLToken(displayText: "@" + (user.handle ?? ""), context: nil))
        } else {
            self.tokenView.add(CLToken(displayText: "@" + (user.handle ?? ""), context: nil))
        }
    }
    // MARK: Sending / Cancelling
    
    func dismiss() {
        
        let messageText = richTextContentView.contentHTML
        let messageSubject = subjectTextField.text

        if (messageText.characters.count == 0) // cancel immediately if message + subject + recipients are empty
            && (messageSubject == nil || messageSubject?.characters.count == 0)
            && tokenView.allTokens.count == 0 {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Draft", style: .destructive, handler: { (action) -> Void in
            //			if let attachments = self.attachmentsCell.attachments {
            //				for attachment in attachments {
            //					attachment.delete()
            //				}
            //			}
            if self.draftMessage != nil {
                self.deleteDraft()
            }
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        let saveDraftText = (draftMessage == nil) ? "Save as Draft" : "Save Draft"
        
        alertController.addAction(UIAlertAction(title: saveDraftText, style: .default, handler: { (action) -> Void in
            
            if self.draftMessage == nil { //new draft
                self.saveAsDraft()
            } else {
                self.updateDraft()
            }
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
        }))
        
        present(alertController, animated: true, completion: nil)
        
        // Draft disabled for now as per IOS-96
        
        //        if let draft = draftMessage {
        //            self.updateDraftFromUI(draft: draft).saveAsDraft()
        //            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        //        } else {
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
            
            recipients.append(token.displayText.replacingOccurrences(of: "@", with: ""))  //FIXME, temporary IMPORTANT, DELETE THIS and uncomment above.
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
            
            let alertController = UIAlertController(title: "Empty subject", message: "This message has no subject line.\n Do you want to send it anyway?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.switchUserInteractionState(true)
            }
            
            let sendAnywayAction = UIAlertAction(title: "Send", style: .default) { (action) in
                
                if let draft = self.draftMessage, let identifier = draft.identifier {
                    
                    MessageOperations.sendDraft(identifier, message: message, subject: subject, recipientUserNames: recipients, callback: { success in
                        // TODO?
                    })
                } else if let replyTo = self.messageToReplyTo {
                    MessageOperations.replyToUserNames(recipients, conversationId: replyTo.conversationId!, message: message, subject: subject, callback: { (success) in
                        // TODO?
                    })
                } else {
                    
                    MessageOperations.sendNewMessage(message, subject: subject, recipientUserNames: recipients, callback: { (success) in
                        // TODO?
                    })
                }
                
                self.navigationController?.dismiss(animated: true, completion: nil)
                self.switchUserInteractionState(true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(sendAnywayAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            if let draft = self.draftMessage, let identifier = draft.identifier {
                
                MessageOperations.sendDraft(identifier, message: message, subject: subject, recipientUserNames: recipients, callback: { success in
                    // TODO?
                })
            } else if let replyTo = self.messageToReplyTo {
                MessageOperations.replyToUserNames(recipients, conversationId: replyTo.conversationId!, message: message, subject: subject, callback: { (success) in
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                MessageOperations.sendNewMessage(message, subject: subject, recipientUserNames: recipients, callback: { (success) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func saveAsDraft() {
        let message = richTextContentView.contentHTML
        let subject = subjectTextField.text ?? ""
        
        var recipients = [String]()
        for token in tokenView.allTokens {
            //			for validtoken in validatedTokens {
            //				if validtoken.isOnHandler && validtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
            //					recipients.append(validtoken.name)
            //				}
            //			}
            recipients.append(token.displayText.replacingOccurrences(of: "@", with: ""))  //FIXME, temporary IMPORTANT, DELETE THIS and uncomment above.
        }
        
        MessageOperations.saveMessageAsDraft(message, subject: subject, recipientUserNames: recipients, callback: { success in
        })
    }
    
    
    func updateDraft() {
        guard let draft = draftMessage else {
            return
        }
        
        let message = richTextContentView.contentHTML
        let subject = subjectTextField.text ?? ""
        
        var recipients = [String]()
        for token in tokenView.allTokens {
            //			for validtoken in validatedTokens {
            //				if validtoken.isOnHandler && validtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
            //					recipients.append(validtoken.name)
            //				}
            //			}
            recipients.append(token.displayText.replacingOccurrences(of: "@", with: ""))  //FIXME, temporary IMPORTANT, DELETE THIS and uncomment above.
        }
        
        MessageOperations.updateDraft(draft.identifier!, message: message, subject: subject, recipientUserNames: recipients, callback: {success in
        })
        
    }
    
    func deleteDraft() {
        guard let draft = draftMessage, let messageId = draft.identifier else {
            return
        }
        
        MessageOperations.deleteMessage(messageId: messageId, callback: { success in
        })
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
    
    func configMsg(_ message: ManagedMessage) -> ManagedMessage {
        
        var receivers = [ManagedUser]()
        for token in tokenView.allTokens {
            for valdtoken in validatedTokens {
                if valdtoken.isOnHandler && valdtoken.name == token.displayText.replacingOccurrences(of: "@", with: ""){
                    receivers.append(ManagedUser.userWithHandle(valdtoken.name, inContext: PersistenceManager.mainManagedContext))
                }
            }
        }
        
        //		var attachments = [Attachment]()
        //		for attachment in attachmentsCell.attachments ?? [Attachment]() {
        //			if let converted = attachment.toManageObjectContext(DatabaseManager.sharedInstance.backgroundContext) {
        //				attachments.append(converted)
        //			}
        //		}
        
        message.recipients = NSSet(array: receivers)
        message.content = richTextContentView.contentHTML
        message.subject = subjectTextField.text ?? ""
        return message
    }
    
    // MARK: UI Utils
    
    func switchUserInteractionState(_ enabled: Bool){
        if !enabled {
            resignAll()
        }
        subjectTextField.isEnabled = enabled
        richTextContentView.isUserInteractionEnabled = enabled
        tokenView.isUserInteractionEnabled = enabled
        ccTokenView.isUserInteractionEnabled = enabled
    }
    
    func resignAll() {
        subjectTextField.resignFirstResponder()
        richTextContentView.resignFirstResponder()
        tokenView.resignFirstResponder()
        ccTokenView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: TokenViewDelegate
    
    func tokenInputView(_ view: CLTokenInputView, didChangeText text: String?) {
        guard let text = text else {
            return
        }
        
        let escapedString = text.replacingOccurrences(of: "@", with: "")
        // OTODO: Enable Back the auto complete feature
        //		delegate?.autoCompleteUserForPrefix(escapedString)
    }
    
    func textColorForTokenView(with token: CLToken) -> UIColor {
        guard token.displayText.lowercased().replacingOccurrences(of: "@", with: "") != "" else {
            return UIColor(rgba: HexCodes.darkGray)
        }
        for validatedToken in validatedTokens {
            if validatedToken.name != "" && validatedToken.name.lowercased() == token.displayText.lowercased().replacingOccurrences(of: "@", with: "") && validatedToken.isOnHandler {
                return UIColor(rgba: HexCodes.lightBlue)
            }
        }
        return UIColor(rgba: HexCodes.darkGray)
    }
    
    func tokenInputView(_ view: CLTokenInputView, didChangeHeightTo height: CGFloat) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tokenInputView(_ view: CLTokenInputView, tokenForText text: String) -> CLToken? {
        return CLToken(displayText: text, context: nil)
    }
    
    func tokenInputViewDidBeginEditing(_ view: CLTokenInputView) {
        if view == tokenView {
            addToContactButton.isHidden = false
        } else {
            addCCContactButton.isHidden = false
        }
        
        activeTokenField = view
        
        if let frame = activeTokenField!.superview?.convert(activeTokenField!.frame, to: nil) {
            let tableY = self.tableView.superview!.convert(self.tableView.frame, to: nil).origin.y
            let insetTop = frame.origin.y + frame.size.height - tableY + 15 // 15 to accomodate for bottom spacing in cells
            self.delegate?.setAutoCompleteViewTopInset(insetTop)
        }
    }
    
    func tokenInputViewDidEndEditing(_ view: CLTokenInputView) {
        if view == tokenView {
            addToContactButton.isHidden = true
        } else {
            addCCContactButton.isHidden = true
        }
        
        activeTokenField = nil
    }
    
    func tokenView(_ view: CLTokenView, didSelect token: CLToken) {
        view.resignFirstResponder()
        ContactCardViewController.showWithHandle(token.displayText.lowercased().replacingOccurrences(of: "@", with: ""))
    }
    
    func tokenView(_ view: CLTokenView, didUnselectToken token: CLToken) {
        
    }
    
    // Fix a bug where more than one token where being deleted with backspace
    func tokenInputView(_ view: CLTokenInputView, didAdd token: CLToken) {
        view.endEditing()
        view.beginEditing()
        
        enableSendButton()
    }
    
    
    func tokenInputView(_ view: CLTokenInputView, didRemove token: CLToken) {
        // Fix a bug where more than one token where being deleted with backspace
        view.endEditing()
        view.beginEditing()
        
        if shouldShowAlertForOriginalRecipientChange(token) {
            let alertController = UIAlertController(title: "New thread", message: "Removing someone from a thread will create a new, seperate thread.", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                view.add(token)
            }))
            
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.originalRecipientsChanged = true
                self.messageToReplyTo = nil
            }))
            
            present(alertController, animated: true, completion: nil)
        }
        
        enableSendButton()
    }
    
    func shouldShowAlertForOriginalRecipientChange(_ token: CLToken) -> Bool {
        if originalRecipientsChanged || messageToReplyTo == nil {
            return false
        }
        
        let escapedToken = token.displayText.replacingOccurrences(of: "@", with: "")
        
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
    
    func startValidation(with string: String) {
        guard string.replacingOccurrences(of: "@", with: "") != "" else {
            return
        }
        
        for validatedToken in validatedTokens {
            if validatedToken.name.lowercased() == string.replacingOccurrences(of: "@", with: "") {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationMessageCellID, for: indexPath) as! ConversationMessageTableViewCell
        
        configureThreadMessageCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }
        
        // Using UITableViewAutomaticDimension was producing lots of autolayout warnings due the auto added constraint for the Height
        configureThreadMessageCell(sizingCell, indexPath: indexPath)
        
        return sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                return max(CGFloat(richTextContentView.editorHeight + 40), CGFloat(300))
            } else if indexPath.row == 4 {
                if FeaturesManager.attachmentsActivated {
                    return max(attachmentsCell.intrinsicContentSize.height + 20, 50+20)
                } else {
                    return 0
                }
            }
            
            return UITableViewAutomaticDimension
        }
        
        configureThreadMessageCell(sizingCell, indexPath: indexPath)
        
        return sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging && !scrollView.isDecelerating {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    // MARK: FilePickerDelegate
    
    func presentFilePicker() {
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data","public.content"], in: UIDocumentPickerMode.open)
        docPicker.delegate = self
        Async.main(after: 0.1) { () -> Void in
            self.present(docPicker, animated: true, completion: nil)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        Async.background { () -> Void in
            if url.startAccessingSecurityScopedResource() {
                let coordinator = NSFileCoordinator()
                coordinator.coordinate(readingItemAt: url, options: NSFileCoordinator.ReadingOptions.resolvesSymbolicLink, error: nil, byAccessor: { (url) -> Void in
                    if let data = NSData(contentsOf: url){
                        self.saveFileToAttachment(data as Data, url: url)
                    } else {
                        print("Unable to read file at url: \(url)")
                    }
                })
                
                url.stopAccessingSecurityScopedResource()
            } else {
                print("Couldn't enter security scope")
            }
        }
    }
    
    func saveFileToAttachment(_ file: Data, url: URL){
        //			guard let filetype = url.pathExtension else {
        //				print("\(url) had no filtype")
        //				return
        //			}
        //			guard let originalFileName = url.lastPathComponent else {
        //				print("\(url) had no filename")
        //				return
        //			}
        //			guard let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).first else {
        //				print("caches directory not found")
        //				return
        //			}
        //			var docsDirURL = URL(fileURLWithPath: docsDir, isDirectory: true)
        //			let filename = UUID().uuidString + ("."+filetype)
        //			docsDirURL = docsDirURL.appendingPathComponent(filename)
        //			DatabaseManager.sharedInstance.backgroundContext.perform { () -> Void in
        //
        //				if (try? file.write(to: docsDirURL, options: [.atomic])) != nil {
        //
        ////					let attachment = Attachment(localFile: docsDirURL, filename: originalFileName)
        //					DatabaseManager.sharedInstance.mainManagedContext.saveRecursively()
        ////					Async.main(block: { () -> Void in
        ////						self.attachmentsCell.attachments?.append(attachment)
        ////					})
        //				} else {
        //					print("Failed to write file")
        //				}
        //			}
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController ?? self
    }
    
    // Mark: ContactsAutoCompleteViewControllerDelegateDelegate
    
    func contactsAutoCompleteDidSelectUser(_ user: ManagedUser) {
        let handle = user.handle
        
        guard handle.characters.count > 0 else {
            return
        }
        
        validatedTokens.append(ValidatedToken(name: handle, isOnHandler: true))
        
        let token = CLToken(displayText: "@\(handle)", context: nil)
        if self.tokenView.isEditing {
            self.tokenView.add(token)
            
        }
        else if self.ccTokenView.isEditing {
            self.ccTokenView.add(token)
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == subjectTextField && internalmessageToReplyTo != nil) {
            
            if (replySubjectChanged) { // already changed subject
                return true
            }
            
            if (string != originalReplySubject) {
                
                let alertController = UIAlertController(title: "New Thread", message: "Changing the subject line of a thread will create a new, separate thread.", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                }))
                
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.replySubjectChanged = true
                    self.messageToReplyTo = nil
                }))
                
                present(alertController, animated: true, completion: nil)
            }
            return false
        }
        
        return true
        
    }
    
    func configureThreadMessageCell(_ cell: ConversationMessageTableViewCell, indexPath: IndexPath) {
        let message = conversations[indexPath.row]
        
        let lastMessage = indexPath.row + 1 >= conversations.count
        //		let primary = message == orderedThreadMessages // What?
        let primary = false // TODO
        //		ConversationTableViewCellHelper.configureCell(cell, message: message, lastMessage: lastMessage, primary: primary)
    }
    
    // MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
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
        
        sendButton.isEnabled = !self.tokenView.allTokens.isEmpty
    }
}


protocol MessageComposeTableViewControllerDelegate {
    func autoCompleteUserForPrefix(_ prefix : String)
    func setAutoCompleteViewTopInset(_ topInset: CGFloat)
}

extension MessageComposeTableViewController: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, shouldInteractWithURL url: URL) -> Bool {
        return false
    }
}
