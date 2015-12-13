//
//  BottomBarActionPluginProvider.swift
//  Handler
//
//  Created by Christian Praiß on 12/12/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class BottomBarActionPluginProvider: NSObject {
    class func plugin(vc: ThreadTableViewController)->BottomBarActionPlugin?{
        return ConversationsBottomBarActionsHandler(vc: vc)
    }
}
