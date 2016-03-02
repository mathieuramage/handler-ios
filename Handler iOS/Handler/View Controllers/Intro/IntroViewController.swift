//
//  IntroViewController.swift
//  Handler
//
//  Created by Christian Praiss on 15/10/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async

class IntroViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var firstView: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var fourthView: UIView!
    var contentView: UIView = UIView()
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    var totalWidth = 0.0
    
    @IBOutlet weak var first_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var first_middle_constraint: NSLayoutConstraint!
    @IBOutlet weak var first_bottom_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var second_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var second_middle_constraint: NSLayoutConstraint!
    @IBOutlet weak var second_bottom_constraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var third_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var third_middle_constraint: NSLayoutConstraint!
    @IBOutlet weak var third_bottom_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var fourth_top_constraint: NSLayoutConstraint!    
    @IBOutlet weak var fourth_middle_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var fourth_bottom_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var fourth_last_constraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalWidth = Double(UIScreen.mainScreen().bounds.width * 4)
        contentView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width * 4, UIScreen.mainScreen().bounds.height))
        firstView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        secondView.frame = CGRectMake(firstView.bounds.width, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        thirdView.frame = CGRectMake(firstView.bounds.width * 2, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        fourthView.frame = CGRectMake(firstView.bounds.width * 3, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        contentView.addSubview(fourthView)
        contentView.addSubview(thirdView)
        contentView.addSubview(secondView)
        contentView.addSubview(firstView)
        
        scrollView.addSubview(contentView)
        
        scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 4, UIScreen.mainScreen().bounds.height)
        scrollView.scrollEnabled = false;
        pageControl.alpha = 0;
        
        self.modifyingConstraints()
    }
    
    func modifyingConstraints(){
        
        first_top_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        first_middle_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        first_bottom_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        
        second_top_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        second_middle_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        second_bottom_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        
        third_top_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        third_middle_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        third_bottom_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        
        fourth_top_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        fourth_middle_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        fourth_bottom_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
        fourth_last_constraint.constant /= (667/UIScreen.mainScreen().bounds.height)
    }
    
//MARK: IBAction methods
    @IBAction func beginButtonPressed(sender: RoundedBorderButton) {
        scrollView.scrollEnabled = true
        UIView.animateWithDuration(1, animations: {
            self.pageControl.alpha = 1
        })
        scrollView.setContentOffset(CGPointMake(firstView.bounds.width, 0), animated: true)
//        pageControl.currentPage = 0
        
        //Removing the first page from the scrollview and reload
        Async.main(after: 0.5) {
            self.firstView.removeFromSuperview();
            self.totalWidth = Double(UIScreen.mainScreen().bounds.width * 3)
            self.contentView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width * 3, UIScreen.mainScreen().bounds.height))
            self.secondView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            self.thirdView.frame = CGRectMake(self.firstView.bounds.width * 1, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            self.fourthView.frame = CGRectMake(self.firstView.bounds.width * 2, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 3, UIScreen.mainScreen().bounds.height)
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
        }

    }
    
    @IBAction func finishWalkthrough(sender: AnyObject) {
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
            pageControl.currentPage = Int((Double(scrollView.contentOffset.x) / totalWidth )*3)
            
        }else{
            pageControl.currentPage = 0
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pageControl.currentPage = Int((Double(scrollView.contentOffset.x) / totalWidth )*3)
        
        let translation = scrollView.panGestureRecognizer.translationInView(self.view)
        
        if (translation.x < 0 && pageControl.currentPage == 1)
        {
            pageControl.alpha = 0;
        }
        else{
            pageControl.alpha = 1;
        }
    }
}
