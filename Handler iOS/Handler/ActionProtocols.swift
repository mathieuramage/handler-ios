//
//  ActionProtocols.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

protocol MessageTableViewCellActions {
    func leftButtonsForData(data message: Message)->[AnyObject]
    func rightButtonsForData(data message: Message)->[AnyObject]
    func rightButtonTriggered(index: Int, data message: Message, callback: (()->Void)?)
    func leftButtonTriggered(index: Int, data message: Message, callback: (()->Void)?)
}
