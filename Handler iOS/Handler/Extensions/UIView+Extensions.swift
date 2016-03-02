//
//  UIView+Extensions.swift
//  Handler
//
//  Created by Christian Praiss on 28/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import Foundation

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}