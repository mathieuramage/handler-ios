//
//  InboxActionHandler.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class InboxActionHandler: MessageTableViewCellActions {
    
    // MARK: Actions
    
    func leftButtonTriggered(index: Int, data message: Message, callback: (() -> Void)?) {
        
        switch index {
        case 0:
            message.isUnread ? message.markAsRead() : message.markAsUnread()
            break;
        default:
            break
        }
        
        defer{
            if let cb = callback {
                cb()
            }
        }
        
        // TODO: Implement actions
    }
    
    func rightButtonTriggered(index: Int, data message: Message, callback: (() -> Void)?) {
        
        switch index {
        case 0:
            message.isFlagged ? message.unflag() : message.flag()
            break;
        case 1:
            if (message.isArchived) {
                if let thread = message.thread {
                    for message in thread.messages! {
                        let m = message as! Message
                        if m.isArchived {
                            m.moveToInbox()
                        }
                    }
                }
                
            } else {
                
                if let thread = message.thread {
                    for message in thread.messages! {
                        let m = message as! Message
                        if !m.isArchived {
                            m.moveToArchive()
                        }
                    }
                }
                
            }
            break
        default:
            break
        }
        
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
            array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.blue), icon: UIImage(named: "Read_Icon"), andTitle: "Read")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.lightBlue), icon: UIImage(named: "Unread_Icon"), andTitle: "Unread")
        }
        return array as [AnyObject]
    }
    
    func rightButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
        if message.isFlagged {
            array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.orange), icon: UIImage(named: "Flag_Icon"), andTitle: "Unflag")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.orange), icon: UIImage(named: "Flag_Icon"), andTitle: "Flag")
        }
        
        if message.isArchived {
            array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "Archive_Icon"), andTitle: "Unarchive")
        }else{
            array.sw_addUtilityButtonWithColor(UIColor(rgba: HexCodes.darkBlue), icon: UIImage(named: "Archive_Icon"), andTitle: "Archive")
        }
        return array as [AnyObject]
    }
}
