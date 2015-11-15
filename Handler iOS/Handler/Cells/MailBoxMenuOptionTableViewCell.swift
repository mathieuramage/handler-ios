//
//  MailBoxMenuOptionTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 14/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class MailBoxMenuOptionTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(self.selected){
            self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        }else{
            self.backgroundColor = UIColor.whiteColor()
        }
        // Configure the view for the selected state
    }
    
}
