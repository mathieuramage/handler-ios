//
//  ActionProtocols.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

protocol MessageTableViewCellActions {
    func leftButtonsForData(data message: LegacyMessage)->[AnyObject]
    func rightButtonsForData(data message: LegacyMessage)->[AnyObject]
    func rightButtonTriggered(index: Int, data message: LegacyMessage, callback: (()->Void)?)
    func leftButtonTriggered(index: Int, data message: LegacyMessage, callback: (()->Void)?)
}
