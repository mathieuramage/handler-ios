//
//  Array+Conversation.swift
//  Handler
//
//  Created by Çağdaş Altınkaya on 12/12/2016.
//  Copyright © 2016 Handler, Inc. All rights reserved.
//

import Foundation

extension Array where Element: Conversation {
    
    var sortedByDate : [Conversation] {
        return self.sorted {
            $0.latestMessage?.createdAt?.compare(($1.latestMessage?.createdAt)! as Date) == ComparisonResult.orderedDescending
        }
    }
    
}
