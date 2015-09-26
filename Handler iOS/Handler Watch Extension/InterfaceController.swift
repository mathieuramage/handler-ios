//
//  InterfaceController.swift
//  Handler Watch Extension
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class InterfaceController: WKInterfaceController {

	@IBOutlet var tableView: WKInterfaceTable!
	
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		
		let messages = WatchDatabaseManager().fetchMessages() ?? [NSManagedObject]()
		tableView.setNumberOfRows(messages.count, withRowType: "mailRow")
		
		for var i = 0; i < messages.count; i++ {
			let message = messages[i]
			let row = tableView.rowControllerAtIndex(i) as! MailRow
			row.message = message
		}

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
