//
//  Protocols.swift
//  Handler
//
//  Created by Christian Praiss on 20/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import CoreData
import HandleriOSSDK

// MARK: UIViewController + show

protocol UIViewControllerShow {
	mutating func show()
	mutating func dismiss()
	var window: UIWindow? { get set }
	func dismissPressed(sender: AnyObject?)
}

extension UIViewControllerShow where Self: UIViewController {
	mutating func show() {
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.windowLevel = UIWindowLevelAlert - 1
		window?.rootViewController = self
        window?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissPressed:")))
		self.window?.makeKeyAndVisible()
		window?.alpha = 0
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.window?.alpha = 1
			}) { (success) -> Void in
		}
	}
}

// MARK: Observers

protocol MailboxCountObserver {
	func mailboxCountDidChange(mailboxType: MailboxType, newCount: Int)
}
extension Array {
	func randomItem() -> Element {
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self[index]
	}
}