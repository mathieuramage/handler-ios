//
//  BottomBarProtocol.swift
//  Handler
//
//  Created by Christian Praiß on 12/13/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

protocol BottomBarActionPlugin {
    func barButtonItemsForThread(thread: Thread?) -> [UIBarButtonItem]
}