//
//  BottomBarActionPluginProvider.swift
//  Handler
//
//  Created by Christian Praiß on 12/12/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class BottomBarActionPluginProvider: NSObject {
    class func plugin(_ vc: ConversationTableViewController)->BottomBarActionPlugin?{
        return ConversationsBottomBarActionsHandler(vc: vc)
    }
}
