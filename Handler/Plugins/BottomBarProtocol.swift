//
//  BottomBarProtocol.swift
//  Handler
//
//  Created by Christian Praiß on 12/13/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

protocol BottomBarActionPlugin {
    func barButtonItemsForThread(_ thread: Thread?) -> [UIBarButtonItem]
}
