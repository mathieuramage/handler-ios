//
//  InboxActionHandler.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class InboxActionHandler: MessageTableViewCellActions {
    
    // MARK: Actions
    
    func leftButtonTriggered(index: Int, data message: Message, callback: (() -> Void)?) {
        defer{
            if let cb = callback {
                cb()
            }
        }
        
        // TODO: Implement actions
    }
    
    func rightButtonTriggered(index: Int, data message: Message, callback: (() -> Void)?) {
        defer{
            if let cb = callback {
                cb()
            }
        }
        
        // TODO: Implement actions
    }
    
    // MARK: Data Source
    
    func leftButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
        if message.isUnread {
            array.sw_addUtilityButtonWithColor(UIColor.hrBlueColor(), icon: UIImage(named: "Read_Icon"), andTitle: "Read")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor.hrBlueColor(), icon: UIImage(named: "Unread_Icon"), andTitle: "Unread")
        }
        return array as [AnyObject]
    }
    
    func rightButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
        array.sw_addUtilityButtonWithColor(UIColor.hrLightGrayColor(), icon: UIImage(named: "More_Dots_Icon"), andTitle: "More")
        if message.isFlagged {
            array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Unflag")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor.hrOrangeColor(), icon: UIImage(named: "Flag_Icon"), andTitle: "Flag")
        }
        
        if message.isArchived {
            array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Unarchive")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor.hrDarkBlueColor(), icon: UIImage(named: "Archive_Icon"), andTitle: "Archive")
        }
        return array as [AnyObject]
    }
}
