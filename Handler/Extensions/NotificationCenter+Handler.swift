//
//  NotificationCenter+Handler.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 17/02/2017.
//  Copyright © 2017 Handler, Inc. All rights reserved.
//

import UIKit

extension NotificationCenter {
	static func when(_ name : Notification.Name, perform block : @escaping (Notification) -> Void) {
		NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: block)
	}
}
