//
//  MessageSenderTableViewCell.swift
//  Handler
//
//  Created by Christian Praiß on 12/9/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MessageSenderTableViewCell: UITableViewCell {
    
    @IBOutlet var senderLabel: UILabel!
    @IBOutlet var senderHandleButton: UIButton!
    @IBOutlet var recipientLabel: UILabel!
    @IBOutlet var timeStampeLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!

    var message: Message? {
        didSet {
            // TODO: Populate cell
        }
    }
    
    @IBAction func didPressUsername(sender: UIButton) {
        if let sender = self.message?.sender {
            ContactCardViewController.showWithUser(sender)
        }
    }
}
