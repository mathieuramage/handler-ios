//
//  MessageAttachmentsTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 08/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

protocol FilePickerDelegate {
    func presentFilePicker()
}

class MessageAttachmentsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var reloadClosure: (()->Void)?
    var filePickerDelegate: FilePickerDelegate?
    var attachments: [Attachment]? = [Attachment]() {
        didSet {
            self.collectionView.reloadSections(NSIndexSet(index: 0))
        }
    }
    weak var filePresentingVC: UIDocumentInteractionControllerDelegate?
    
    // MARK: Setup / Teardown
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        collectionView.registerNib(UINib(nibName: "AddAttachmentView", bundle: nil), forCellWithReuseIdentifier: "addAttachmentCell")
        
        collectionView.registerNib(UINib(nibName: "AttachmentThumbnailView", bundle: nil), forCellWithReuseIdentifier: "attachmentCell")
        // Initialization code
    }
    
    deinit{
        collectionView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    // MARK: CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row + 1 == collectionView.numberOfItemsInSection(0) {
            filePickerDelegate?.presentFilePicker()
        } else {
            if indexPath.row < attachments?.count, let attachment = attachments?[indexPath.row] {
                if let presentingVC = filePresentingVC {
                    attachment.interactionController?.delegate = presentingVC
                    attachment.interactionController?.presentPreviewAnimated(true)
                }
            }
        }
    }
    
    // MARK: CollectionView DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let attachmentsCount = attachments?.count {
            return attachmentsCount + 1
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("attachmentCell", forIndexPath: indexPath) as! AttachmentThumbnailCollectionViewCell
        
        if indexPath.row + 1 == collectionView.numberOfItemsInSection(0) {
            
            return collectionView.dequeueReusableCellWithReuseIdentifier("addAttachmentCell", forIndexPath: indexPath) as! AddAttachmentCollectionViewCell
            
        }else if indexPath.row < attachments?.count {
            cell.attachment = attachments?[indexPath.row]
        }else{
            cell.attachment = nil
        }
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
	
	override func intrinsicContentSize() -> CGSize {
		return collectionView.contentSize
	}
}
