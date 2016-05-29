//
//  ActionProtocols.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

protocol MessageTableViewCellActions {
    func leftButtonsForData(data message: Message)->[AnyObject]
    func rightButtonsForData(data message: Message)->[AnyObject]
    func rightButtonTriggered(index: Int, data message: Message, callback: (()->Void)?)
    func leftButtonTriggered(index: Int, data message: Message, callback: (()->Void)?)
}
