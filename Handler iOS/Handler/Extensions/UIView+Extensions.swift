//
//  UIView+Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 28/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation

extension SendInvitationView {

	func show(){
		showWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
		showWindow!.windowLevel = UIWindowLevelAlert
		self.center = CGPointMake(CGRectGetMidX(showWindow!.bounds), CGRectGetMidY(showWindow!.bounds));
		showWindow!.addSubview(self)
		showWindow!.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
		showWindow?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
		self.showWindow?.makeKeyAndVisible()
		showWindow?.alpha = 0
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.showWindow?.alpha = 1
			}) { (success) -> Void in
		}
	}
	
	func dismiss(){
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.showWindow?.alpha = 0
			}) { (success) -> Void in
				self.showWindow = nil
		}
	}
}