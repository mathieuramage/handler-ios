//
//  FormatterProtocols.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

protocol MessageTableViewCellFormatter {
    func populateView(data message: LegacyMessage, view: MessageTableViewCell)
    func refreshFlags(data message: LegacyMessage, view: MessageTableViewCell)
    func leftButtonsForData(data message: LegacyMessage)->[AnyObject]
    func rightButtonsForData(data message: LegacyMessage)->[AnyObject]
}

protocol MessageContentCellFormatter {
    func populateView(data message: LegacyMessage?, view: ThreadMessageTableViewCell)
    func populateView(data message: LegacyMessage?, view: ThreadMessageTableViewCell, lastMessage: Bool, primary: Bool)
}
