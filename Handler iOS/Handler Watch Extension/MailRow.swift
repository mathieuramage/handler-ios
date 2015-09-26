//
//  MailRow.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import WatchKit
import CoreData

class MailRow: NSObject {
	@IBOutlet var subjectlabel: WKInterfaceLabel!
	@IBOutlet var contentLabel: WKInterfaceLabel!

	var message: NSManagedObject? {
		didSet {
			subjectlabel.setText(message?.valueForKey("subject") as? String)
			contentLabel.setText(message?.valueForKey("content") as? String)
		}
	}
}
