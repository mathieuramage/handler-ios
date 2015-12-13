//
//  MessageTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async

class MessageTableViewCell: SWTableViewCell {
    
    @IBOutlet weak var readFlaggedImageView: UIImageView!
    @IBOutlet weak var senderProfileImageView: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var senderHandleLabel: UILabel!
    @IBOutlet weak var messageSubjectLabel: UILabel!
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var messageContentPreviewLabel: UILabel!
    @IBOutlet weak var additionalsStackView: UIStackView!
    
    @IBOutlet weak var threadCountLabel: UILabel!
    @IBOutlet weak var attachmentIconView: UIImageView!
    @IBOutlet weak var repliedIconView: UIImageView!
}
