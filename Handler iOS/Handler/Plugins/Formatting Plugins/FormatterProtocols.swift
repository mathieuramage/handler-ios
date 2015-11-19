//
//  FormatterProtocols.swift
//  Handler
//
//  Created by Christian Praiss on 19/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

protocol MessageTableViewCellFormatter {
    func populateView(data message: Message, view: MessageTableViewCell)
    func refreshFlags(data message: Message, view: MessageTableViewCell)
    func leftButtonsForData(data message: Message)->[AnyObject]
    func rightButtonsForData(data message: Message)->[AnyObject]
}
