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
    
    @IBOutlet weak var autoCompleteTopConstraint: NSLayoutConstraint!    
    
    var messageComposerController : MessageComposeTableViewController?
    var autoCompleteViewController : ContactsAutoCompleteViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoCompleteContainerView.hidden = true
        
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillShowNotification,
            object: nil, queue: nil,
            usingBlock: { notification in
                
                if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().size {
                    
                    let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
                    
                    self.messageComposerController?.tableView.contentInset = contentInsets
                    self.messageComposerController?.tableView.scrollIndicatorInsets = contentInsets
                    
                    self.autoCompleteViewController?.tableView.contentInset = contentInsets
                    self.autoCompleteViewController?.tableView.scrollIndicatorInsets = contentInsets
                }
                
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillHideNotification,
            object: nil, queue: nil,
            usingBlock: { notification in
                
                self.messageComposerController?.tableView.contentInset = UIEdgeInsetsZero
                self.messageComposerController?.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
                
                self.autoCompleteViewController?.tableView.contentInset = UIEdgeInsetsZero
                self.autoCompleteViewController?.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        })
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
    
    func setAutoCompleteViewTopInset(topInset : CGFloat) {
        autoCompleteTopConstraint.constant = topInset
        self.view.layoutIfNeeded()
    }
    
    
    //MARK : AutoCompleteDelegate    
    func contactsAutoCompleteDidSelectUser(controller: ContactsAutoCompleteViewController, user: User) {
        messageComposerController?.contactsAutoCompleteDidSelectUser(controller, user: user)
    }
    
}