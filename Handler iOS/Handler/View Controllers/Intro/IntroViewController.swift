//
//  IntroViewController.swift
//  Handler
//
//  Created by Christian Praiss on 15/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {
		
	@IBOutlet var firstView: UIView!
	@IBOutlet var secondView: UIView!
	@IBOutlet var thirdView: UIView!
	@IBOutlet var fourthView: UIView!
	var contentView: UIView = UIView()
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet var scrollView: UIScrollView!
	var totalWidth = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
        let layer = CAGradientLayer.gradientLayerForBounds(UIScreen.mainScreen().bounds)
        self.view.layer.insertSublayer(layer, atIndex: 0)
        
		totalWidth = Double(UIScreen.mainScreen().bounds.width * 4)
		contentView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width * 4, UIScreen.mainScreen().bounds.height))
		firstView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		secondView.frame = CGRectMake(firstView.bounds.width, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		thirdView.frame = CGRectMake(firstView.bounds.width * 2, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
		fourthView.frame = CGRectMake(firstView.bounds.width * 3, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)

		contentView.addSubview(thirdView)
		contentView.addSubview(fourthView)
		contentView.addSubview(secondView)
		contentView.addSubview(firstView)
		
		scrollView.addSubview(contentView)

		scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 4, UIScreen.mainScreen().bounds.height)
	}
	
	@IBAction func beginButtonPressed(sender: RoundedBorderButton) {
		scrollView.setContentOffset(CGPointMake(firstView.bounds.width, 0), animated: true)
	}
	
	@IBAction func finishWalkthrough(sender: UIButton) {
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "didFinishWalkthrough")
		NSUserDefaults.standardUserDefaults().synchronize()
		UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
			AppDelegate.sharedInstance().window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
			}, completion: nil)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		if scrollView.contentOffset.x > 0 {
			pageControl.currentPage = Int((Double(scrollView.contentOffset.x) / totalWidth )*4)
		}else{
			pageControl.currentPage = 0
		}
	}
}
