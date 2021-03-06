//
//  AttachmentThumbnailView.swift
//  Handler
//
//  Created by Christian Praiss on 08/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Kingfisher
import Async
import QuartzCore

class AttachmentThumbnailCollectionViewCell: UICollectionViewCell {

    var attachment: Attachment? {
        didSet {
			self.loadUI()
        }
    }
	
	func loadUI(){
		Async.main { () -> Void in
			if let imageTuple = self.attachment?.previewImage() {
				self.contentImageView.contentMode = imageTuple.1
				self.contentImageView.image = imageTuple.0
			}
			self.filenameLabel.text = self.attachment?.filename
			self.fileMetaLabel.text = (self.attachment?.displayFileType() ?? "") + " - " + (self.attachment?.fileSizeDisplayString() ?? "")
		}
	}
	
	func update(notification: NSNotification){
		if let userinfo = notification.userInfo, let id = userinfo["id"] as? String {
			if id == self.attachment?.id {
				loadUI()
			}
		}
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "update:", name: AttachmentDownloadDidFinishNotification, object: nil)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.hrLightGrayColor().CGColor
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
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