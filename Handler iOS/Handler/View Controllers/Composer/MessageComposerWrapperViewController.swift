//
//  MessageComposerWrapperViewController.swift
//  Handler
//
//  Created by Otávio on 21/02/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class MessageComposerWrapperViewController: UIViewController {
    
    var messageToReplyTo : Message?
    
    var messageComposerController : MessageComposeTableViewController? {
        get {
            if let vc = self.childViewControllers[0] as? MessageComposeTableViewController  {
                return vc
            }
            return nil
        }
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
                composerTableViewController.messageToReplyTo = messageToReplyTo
            }
        }
    }
}
