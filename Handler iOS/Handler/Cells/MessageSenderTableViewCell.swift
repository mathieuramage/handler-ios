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

    var sender: User?
    
    @IBAction func didPressUsername(sender: UIButton) {
        if let sender = self.sender {
            ContactCardViewController.showWithUser(sender)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)
    }
}
