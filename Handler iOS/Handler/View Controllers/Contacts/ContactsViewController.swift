//
//  ContactsViewController.swift
//  Handler
//
//  Created by Cagdas Altinkaya on 22/4/16.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()

//		let divider =  segmentedControlDividerImage()
		//		segmentedControl.setDividerImage(divider, forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
		//		segmentedControl.setDividerImage(divider, forLeftSegmentState: .Highlighted, rightSegmentState: .Normal, barMetrics: .Default)
		//		segmentedControl.setDividerImage(divider, forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
		//		segmentedControl.setDividerImage(divider, forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
		//		segmentedControl.setDividerImage(divider, forLeftSegmentState: .Normal, rightSegmentState: .Highlighted, barMetrics: .Default)
		//		segmentedControl.setDividerImage(divider, forLeftSegmentState: .Highlighted, rightSegmentState: .Selected, barMetrics: .//        segmentedControl.setDividerImage(divider, forLeftSegmentState: .Selected, rightSegmentState: .Highlighted, barMetrics: .Default)
//		segmentedControl.setDividerImage(divider, forLeftSegmentState: [.Selected, .Highlighted, .Normal], rightSegmentState: [.Selected, .Highlighted, .Normal], barMetrics: .Default)

	}

	// MARK: - UITableViewDataSource
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("contactTableViewCell", forIndexPath: indexPath) as! ContactTableViewCell
		cell.profileImageView.image = UIImage.randomGhostImage()
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	}

	@IBAction func segmentedControlValueChanged(sender: AnyObject) {
	}

//	private func segmentedControlDividerImage() -> UIImage {
//		let rect = CGRect(x: 0, y: 0, width: 15, height: 28)
//		UIGraphicsBeginImageContext(rect.size)
//		let context = UIGraphicsGetCurrentContext()
//		CGContextSetFillColorWithColor(context, UIColor(rgba: HexCodes.lightBlue).CGColor)
//		CGContextFillRect(context, rect);
//		let image = UIGraphicsGetImageFromCurrentImageContext()
//		UIGraphicsEndImageContext()
//		return image
//	}
}
