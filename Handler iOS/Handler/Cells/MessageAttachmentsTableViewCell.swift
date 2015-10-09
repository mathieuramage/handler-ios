//
//  MessageAttachmentsTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 08/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MessageAttachmentsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var collectionView: UICollectionView!
	var reloadClosure: (()->Void)?
	var attachments: [Attachment] = [Attachment]() {
		didSet {
			self.collectionView.reloadSections(NSIndexSet(index: 0))
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
		collectionView.registerNib(UINib(nibName: "AttachmentThumbnailView", bundle: nil), forCellWithReuseIdentifier: "attachmentCell")
        // Initialization code
    }
	
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	deinit{
		collectionView.removeObserver(self, forKeyPath: "contentSize")
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return attachments.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("attachmentCell", forIndexPath: indexPath) as! AttachmentThumbnailCollectionViewCell
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(collectionView.bounds.size.width, 50)
	}

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if let keyPath = keyPath where keyPath == "contentSize" {
			reloadClosure?()
		}
	}
}
