//
//  MailBoxMenuOptionTableViewCell.swift
//  Handler
//
//  Created by Christian Praiss on 14/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class MailBoxMenuOptionTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(self.isSelected){
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        } else {
            self.backgroundColor = UIColor.white
        }
        // Configure the view for the selected state
    }
    
}
