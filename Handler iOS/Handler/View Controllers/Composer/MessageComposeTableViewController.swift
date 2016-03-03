//
//  MessageComposeTableViewController.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import HandlerSDK
import Async

class MessageComposeTableViewController: UITableViewController, CLTokenInputViewDelegate, UITextViewDelegate, FilePickerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, ContactSelectionDelegate {
    
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
    
    var addContactToCC = false
    
    private var internalmessageToReplyTo: Message?
    var messageToReplyTo: Message? {
        set(new){
            if new?.managedObjectContext != MailDatabaseManager.sharedInstance.backgroundContext {
                self.internalmessageToReplyTo = new?.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext)
            }else{
                self.internalmessageToReplyTo = new
            }
        }
        
        get {
            return self.internalmessageToReplyTo
        }
    }
    var messageToForward: Message?
    private var internalDraftmessage: Message?
    var draftMessage: Message? {
        set(new){
            if new?.managedObjectContext != MailDatabaseManager.sharedInstance.backgroundContext {
                self.internalDraftmessage = new?.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext)
            }else{
                self.internalDraftmessage = new
            }
        }
        
        get {
            return self.internalDraftmessage
        }
    }
    
    @IBOutlet weak var tokenView: CLTokenInputView!
    @IBOutlet weak var ccTokenView: CLTokenInputView!
    
    @IBOutlet weak var addToContactButton: UIButton!
    @IBOutlet weak var addCCContactButton: UIButton!
    
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
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
        
        tableView.tableFooterView = UIView()
        
        // UI Configuration
        
        if let draft = draftMessage {
            
            if let recipients = draft.recipients?.allObjects as? [User] {
                for recipient in recipients {
                    if let handle = recipient.handle {
                        tokenView.addToken(CLToken(displayText: "@\(handle)", context: nil))
                        startValidationWithString("@\(handle)")
                    }
                }
            }
            
            self.subjectTextField.text = draft.subject
            self.contentTextView.text = draft.content
            attachmentsCell.attachments = draft.attachments?.allObjects as? [Attachment]
            
        }else{
            
            if let message = messageToReplyTo, let sender = message.sender?.handle {
                self.title = "New Reply"
                tokenView.addToken(CLToken(displayText: "@\(sender)", context: nil))
                startValidationWithString("@\(sender)")
                
                if message.hasReplyPrefix() {
                    subjectTextField.text = message.subject
                }
                else {
                    subjectTextField.text = "\(message.replyPrefix) \(message.subject ?? "")"
                }
            }
            if let receivers = messageToReplyTo?.recipientsWithoutSelf(), let all = receivers.allObjects as? [User] {
                for receiver in all {
                    ccTokenView.addToken(CLToken(displayText: "@\(receiver.handle!)", context: nil))
                    startValidationWithString("@\(receiver.handle!)")
                }
            }
            if let msg = messageToForward {
                attachmentsCell.attachments = msg.attachments?.allObjects as? [Attachment]
            }
        }
        
        attachmentsCell.filePresentingVC = self
        attachmentsCell.reloadClosure = {[unowned self] ()->Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        attachmentsCell.filePickerDelegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillShowNotification,
            object: nil, queue: nil,
            usingBlock: { notification in
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                    
                    self.delegate?.setAutoCompleteInsets(contentInsets)
                    
                    if let activeTokenField = self.activeTokenField {
                        let rect = self.tableView.convertRect(activeTokenField.bounds, fromView: activeTokenField)
                        self.tableView.contentOffset = CGPointMake(0, rect.origin.y)
                    }
                    
                    self.keyboardFirstTime = false
                }
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillHideNotification,
            object: nil, queue: nil,
            usingBlock: { notification in
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                    
                    self.tableView.contentInset = contentInsets
                    self.delegate?.setAutoCompleteInsets(contentInsets)
                }
        })
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
    
    func didSelectUser(user: User) {
        navigationController?.popViewControllerAnimated(true)
        validatedTokens.append(ValidatedToken(name: user.handle ?? "", isOnHandler: true))
        if addContactToCC {
            self.ccTokenView.addToken(CLToken(displayText: "@" + (user.handle ?? ""), context: nil))
        }else{
            self.tokenView.addToken(CLToken(displayText: "@" + (user.handle ?? ""), context: nil))
        }
    }
    // MARK: Sending / Cancelling
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        if let draft = draftMessage {
            self.updateDraftFromUI(draft: draft).saveAsDraft()
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "Save as draft", message: "Do you want to save this message as a draft?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Save as Draft", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.createMessageFromUI().saveAsDraft()
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                if let attachments = self.attachmentsCell.attachments {
                    for attachment in attachments {
                        attachment.delete()
                    }
                }
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func send(sender: UIBarButtonItem) {
        switchUserInteractionState(false, sender: sender)
        
        let message = createMessageFromUI()
        
        if !message.hasValidSubject() {
            let alertController = UIAlertController(title: nil, message: "You are about to send a message without subject, are you sure?", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                self.switchUserInteractionState(true, sender: sender)
            }
            
            let sendAnywayAction = UIAlertAction(title: "Send", style: .Default) { (action) in
                HRActionsManager.enqueueMessage(message, replyTo: self.messageToReplyTo)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                
                self.switchUserInteractionState(true, sender: sender)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(sendAnywayAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            if !message.isValidToSend() {
                var errorPopup = ErrorPopupViewController()
                errorPopup.displayMessageLabel.text = "You need at least one receiver and a subject / content"
                errorPopup.show()
                switchUserInteractionState(true, sender: sender)
                return
            }
            
            HRActionsManager.enqueueMessage(message, replyTo: messageToReplyTo)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func updateDraftFromUI(draft draft: Message) -> Message {
        configMsg(draft)
        return draft
    }
    
    func createMessageFromUI() -> Message {
        let message = Message(managedObjectContext: MailDatabaseManager.sharedInstance.backgroundContext)
        configMsg(message)
        
        return message
    }
    
    func configMsg(message: Message)->Message {
        
        var receivers = [User]()
        for token in tokenView.allTokens {
            for valdtoken in validatedTokens {
                if valdtoken.isOnHandler && valdtoken.name == token.displayText.stringByReplacingOccurrencesOfString("@", withString: ""){
                    receivers.append(User.fromHandle(valdtoken.name))
                }
            }
        }
        
        var attachments = [Attachment]()
        for attachment in attachmentsCell.attachments ?? [Attachment]() {
            if let converted = attachment.toManageObjectContext(MailDatabaseManager.sharedInstance.backgroundContext) {
                attachments.append(converted)
            }
        }
        
        message.attachments = NSSet(array: attachments)
        message.recipients = NSSet(array: receivers)
        message.content = contentTextView.text
        message.subject = subjectTextField.text ?? ""
        return message
    }
    
    // MARK: UI Utils
    
    func switchUserInteractionState(enabled: Bool, sender: UIBarButtonItem? = nil){
        if !enabled {
            resignAll()
        }
        sender?.enabled = enabled
        subjectTextField.enabled = enabled
        contentTextView.userInteractionEnabled = enabled
        tokenView.userInteractionEnabled = enabled
        ccTokenView.userInteractionEnabled = enabled
    }
    
    func resignAll(){
        subjectTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
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
    }
    
    // Fix a bug where more than one token where being deleted with backspace
    func tokenInputView(view: CLTokenInputView, didRemoveToken token: CLToken) {
        view.endEditing()
        view.beginEditing()
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
        APICommunicator.sharedInstance.checkUserWithCallback(string.stringByReplacingOccurrencesOfString("@", withString: "")) { (user, error) in
            guard let user = user else {
                self.validatedTokens.append(ValidatedToken(name: string.stringByReplacingOccurrencesOfString("@", withString: ""), isOnHandler: false))
                self.tokenView.validatedString(string, withResult: false)
                self.ccTokenView.validatedString(string, withResult: false)
                return
            }
            self.validatedTokens.append(ValidatedToken(name: string.stringByReplacingOccurrencesOfString("@", withString: ""), isOnHandler: true, user: user))
            self.tokenView.validatedString(user.handle, withResult: true)
            self.tokenView.reloadTokenWithTitle(user.handle)
            self.ccTokenView.validatedString(user.handle, withResult: true)
            self.ccTokenView.reloadTokenWithTitle(user.handle)
        }
    }
    
    // MARK: TableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return max(CGFloat(contentTextView.contentSize.height + 40), CGFloat(300))
        } else if indexPath.row == 4 {
            if FeaturesManager.attachmentsActivated {
                return max(attachmentsCell.intrinsicContentSize().height + 20, 50+20)
            }else{
                return 0
            }
        }
        return UITableViewAutomaticDimension
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
        MailDatabaseManager.sharedInstance.backgroundContext.performBlock { () -> Void in
            
            if file.writeToURL(docsDirURL, atomically: true) {
                
                let attachment = Attachment(localFile: docsDirURL, filename: originalFileName)
                MailDatabaseManager.sharedInstance.saveContext()
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
    
    // Mark: AutoCompleteDelegate
    
    func contactsAutoCompleteDidSelectUser(controller: ContactsAutoCompleteViewController, user: User) {
        guard let handle = user.handle else {
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
}


protocol MessageComposeTableViewControllerDelegate {
    func autoCompleteUserForPrefix(prefix : String)
    func setAutoCompleteInsets(insets : UIEdgeInsets)
}
