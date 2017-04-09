//
//  UIViewController+Animations.swift
//  Handler
//
//  Created by Marco Antonio Nascimento on 08.04.17.
//  Copyright © 2017 Handler, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
	func showTitleFadeIn(title: String) {
		let fadeTextAnimation = CATransition()
		fadeTextAnimation.duration = 0.2
		fadeTextAnimation.type = kCATransitionFade
		
		navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
		navigationItem.title = title
	}
}
