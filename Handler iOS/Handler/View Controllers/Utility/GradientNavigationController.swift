//
//  GradientNavigationController.swift
//  Handler
//
//  Created by Christian Praiss on 21/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit

class GradientNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationBar.tintColor = UIColor.whiteColor()
		let fontDictionary = [ NSForegroundColorAttributeName:UIColor.whiteColor() ]
		self.navigationBar.titleTextAttributes = fontDictionary
		self.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
		self.navigationBar.translucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func imageLayerForGradientBackground() -> UIImage {
		
		var updatedFrame = self.navigationBar.bounds
		// take into account the status bar
		updatedFrame.size.height += 20
		let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
		UIGraphicsBeginImageContext(layer.bounds.size)
		layer.renderInContext(UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext() 
		return image
	}
	

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
