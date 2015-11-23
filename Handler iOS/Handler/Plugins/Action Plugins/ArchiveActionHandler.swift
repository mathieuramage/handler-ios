//
//  ArchiveActionHandler.swift
//  Handler
//
//  Created by Guillaume Kermorgant on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

class ArchiveActionHandler: MessageTableViewCellActions {
    
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
            switch index {
            case 0:
                message.isFlagged ? message.unflag() : message.flag()
            case 1:
                message.isArchived ? message.moveToInbox() : message.moveToArchive()
            case 2:
                reply(data: message)
            default:
                break
            }
            if let cb = callback {
                cb()
            }
            
            // TODO: Add success messsages
        }
    }
    
    // MARK: Data Source
    
    func leftButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
        return array as [AnyObject]
    }
    
    func rightButtonsForData(data message: Message)->[AnyObject]{
        let array = NSMutableArray()
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
        array.sw_addUtilityButtonWithColor(UIColor.hrGreenColor(), icon: UIImage(named: "Reply"), andTitle: "Reply")
        return array as [AnyObject]
    }
    
    func reply(data message: Message) {
        
        // TODO: Implement reply action
        return
    }
}

