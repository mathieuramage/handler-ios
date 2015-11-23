//
//  SentActionHandler.swift
//  Handler
//
//  Created by Guillaume Kermorgant on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

class SentActionHandler: MessageTableViewCellActions {
    
    // MARK: Actions
    
    func leftButtonTriggered(index: Int, data message: Message, callback: (() -> Void)?) {
        defer{
            if let cb = callback {
                cb()
            }
        }
    }
    
    func rightButtonTriggered(index: Int, data message: Message, callback: (() -> Void)?) {
        defer{
            switch index {
            case 0:
                message.isFlagged ? message.unflag() : message.flag()
            case 1:
                reply(data: message)
            default:
                break
            }
            if let cb = callback {
                cb()
            }
        }
        
        // TODO: Add success message
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
        array.sw_addUtilityButtonWithColor(UIColor.hrGreenColor(), icon: UIImage(named: "Reply"), andTitle: "Reply")
        return array as [AnyObject]
    }
    
    func reply(data message: Message) {
        
//        NSNotificationCenter.defaultCenter().postNotificationName("ReplyToMessage", object: message)
        return
    }
}