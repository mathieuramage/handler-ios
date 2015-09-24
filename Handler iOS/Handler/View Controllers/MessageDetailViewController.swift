//
//  MessageDetailViewController.swift
//  Handler
//
//  Created by Christian Praiss on 23/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MessageDetailViewController: UITableViewController {
	
	@IBOutlet weak var messageContentLabel: UILabel!
	@IBOutlet weak var messageSenderProfileImageView: UIImageView!
	@IBOutlet weak var sentAtLabel: UILabel!
	@IBOutlet weak var messageSubjectLabel: UILabel!
	@IBOutlet weak var messageSenderHandleButton: UIButton!
	
	var message: Message? {
		didSet {
			message?.removeLabelWithID("UNREAD")
		}
	}
	lazy var left: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Left_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	lazy var right: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Right_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	lazy var flag: UIBarButtonItem = {
		return UIBarButtonItem(image: UIImage(named: "Flag_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	lazy var archive: UIBarButtonItem = {
			return UIBarButtonItem(image: UIImage(named: "Archive_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
		}()
	lazy var reply: UIBarButtonItem = {
				return UIBarButtonItem(image: UIImage(named: "Reply_toolbar"), style: UIBarButtonItemStyle.Plain, target: self, action: "action:")
	}()
	let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
		left.enabled = false
		right.enabled = false
		tableView.tableFooterView = UIView()
		if let message = message {
			
			// Message specific
			messageContentLabel.text = message.content
			messageSubjectLabel.text = message.subject

			// User specific
			if let urlString = message.sender?.profile_picture_url, let profileUrl = NSURL(string: urlString) {
				messageSenderProfileImageView.sd_setImageWithURL(profileUrl)
			}
			if let handle = message.sender?.handle {
				messageSenderHandleButton.setTitle("@\(handle)", forState: UIControlState.Normal)
			}
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationController!.toolbar!.items = [left, space, right, space, flag, space, archive, space, reply]
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func action(item: UIBarButtonItem){
		switch item {
		case left:
			
			break;
		case right:
			
			break;
		case flag:
			let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
			cont.addAction(UIAlertAction(title: "Flag", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				message?.addLabelWithID("FLAGGED")
				// TODO: Add success message
			}))
			cont.addAction(UIAlertAction(title: "Mark as unread", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				message?.addLabelWithID("UNREAD")
				// TODO: Add success message
			}))
			cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
			presentViewController(cont, animated: true, completion: nil)
			break;
		case archive:
			let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
			cont.addAction(UIAlertAction(title: "Archive", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				message?.removeLabelWithID("INBOX")
				// TODO: Add success message
			}))
			cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
			presentViewController(cont, animated: true, completion: nil)
			break;
		case reply:
			let cont = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
			cont.addAction(UIAlertAction(title: "Reply", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				// TODO: Add reply UI
			}))
			cont.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
			presentViewController(cont, animated: true, completion: nil)
			break;
		default:
			break;
		}
	}
}
