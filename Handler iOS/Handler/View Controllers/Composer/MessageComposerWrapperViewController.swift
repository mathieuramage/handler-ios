//
//  MessageComposerWrapperViewController.swift
//  Handler
//
//  Created by Otávio on 21/02/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class MessageComposerWrapperViewController: UIViewController, AutoCompleteDelegate, MessageComposeTableViewControllerDelegate {
    
    var messageToReplyTo : Message?
    
    @IBOutlet weak var autoCompleteContainerView: UIView!
    
    @IBOutlet weak var topInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomInsetConstraint: NSLayoutConstraint!
    
    var messageComposerController : MessageComposeTableViewController?
    var autoCompleteViewController : ContactsAutoCompleteViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoCompleteContainerView.hidden = true
    }
    
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        self.messageComposerController?.dismiss(sender)
    }
    
    @IBAction func send(sender: UIBarButtonItem) {
        self.messageComposerController?.send(sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "embedComposer" {
            
            if let composerTableViewController = segue.destinationViewController as? MessageComposeTableViewController {
                self.messageComposerController = composerTableViewController
                composerTableViewController.delegate = self
                composerTableViewController.messageToReplyTo = messageToReplyTo
            }
        } else if segue.identifier == "embedAutoComplete" {
            
            if let autoCompleteViewController = segue.destinationViewController as? ContactsAutoCompleteViewController {
                self.autoCompleteViewController = autoCompleteViewController
                autoCompleteViewController.delegate = self
                autoCompleteViewController.view.hidden = true
            }
            
        }
    }
    
    //MARK : MessageComposeTableViewControllerDelegate
    func autoCompleteUserForPrefix(prefix : String) {
        autoCompleteContainerView.hidden = prefix == ""
        autoCompleteViewController?.autoCompleteUserForPrefix(prefix)
    }
    
    func setAutoCompleteViewInsets(inset : UIEdgeInsets) {
        self.topInsetConstraint.constant = inset.top
        self.bottomInsetConstraint.constant = inset.bottom
        self.view.layoutIfNeeded()
    }
    
    
    //MARK : AutoCompleteDelegate    
    func contactsAutoCompleteDidSelectUser(controller: ContactsAutoCompleteViewController, user: User) {
        messageComposerController?.contactsAutoCompleteDidSelectUser(controller, user: user)
    }
    
}