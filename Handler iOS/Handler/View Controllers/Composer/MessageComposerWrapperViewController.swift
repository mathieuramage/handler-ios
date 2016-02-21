//
//  MessageComposerWrapperViewController.swift
//  Handler
//
//  Created by Otávio on 21/02/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit

class MessageComposerWrapperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    weak var messageComposerController : MessageComposeTableViewController!

    @IBAction func dismiss(sender: UIBarButtonItem) {
        self.messageComposerController.dismiss(sender)
    }

    @IBAction func send(sender: UIBarButtonItem) {
        self.messageComposerController.send(sender)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedComposer" {
            messageComposerController = segue.destinationViewController as! MessageComposeTableViewController
            messageComposerController.wrapperController = self
        }
    }
}
