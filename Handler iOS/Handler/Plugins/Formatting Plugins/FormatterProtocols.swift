//
//  FormatterProtocols.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

protocol MessageTableViewCellFormatter {
    func populateView(data message: Message, view: MessageTableViewCell)
    func refreshFlags(data message: Message, view: MessageTableViewCell)
    func leftButtonsForData(data message: Message)->[AnyObject]
    func rightButtonsForData(data message: Message)->[AnyObject]
}

protocol MessageContentCellFormatter {
    func populateView(data message: Message?, view: MessageContentTableViewCell)
    func populateView(data message: Message?, view: MessageSenderTableViewCell)
}
