//
//  AttachmentThumbnailView.swift
//  Handler
//
//  Created by Christian Praiss on 08/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import WebImage
import Async
import QuartzCore

class AttachmentThumbnailCollectionViewCell: UICollectionViewCell {

    var attachment: Attachment? {
        didSet {
            Async.main { () -> Void in
                if let imageTuple = self.attachment?.previewImage() {
                    self.contentImageView.contentMode = imageTuple.1
                    self.contentImageView.image = imageTuple.0
                }
                self.filenameLabel.text = self.attachment?.filename
                self.fileMetaLabel.text = (self.attachment?.displayFileType() ?? "") + " - " + (self.attachment?.fileSizeDisplayString() ?? "")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.hrLightGrayColor().CGColor
    }
    
	@IBOutlet weak var contentImageView: UIImageView!
	@IBOutlet weak var filenameLabel: UILabel!
	@IBOutlet weak var fileMetaLabel: UILabel!
	@IBOutlet weak var fileTypeImageView: UIImageView!

}

class AddAttachmentCollectionViewCell: UICollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.hrLightGrayColor().CGColor
    }
}