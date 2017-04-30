//
//  UIImage+HanderImages.swift
//  Handler
//
//  Created by Christian Praiss on 25/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import Foundation
import UIKit

let ghostImageNames = ["ghost_black", "ghost_blue", "ghost_green", "ghost_grey", "ghost_purple", "ghost_yellow", "ghost_red"]

extension UIImage {
	class func randomGhostImage() -> UIImage {
		return UIImage(named: ghostImageNames.randomItem())!
	}
	
	class func imageForTwitterStatus(_ status: TwitterFriendshipStatus)->UIImage?{
		switch status {
		case .follower:
			return UIImage(named: "Follow_Icon")
		case .following:
			return UIImage(named: "Followed_Icon")
		case .unknown:
			return UIImage(named: "Follow Unknown Icon")
		}
	}
	
	func imageResize (sizeChange:CGSize)-> UIImage{
		
		let hasAlpha = true
		let scale: CGFloat = 0.0
		
		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage!
	}
}

