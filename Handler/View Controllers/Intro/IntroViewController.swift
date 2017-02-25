//
//  IntroViewController.swift
//  Handler
//
//  Created by Christian Praiss on 15/10/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Async

class IntroViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var firstView: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var fourthView: UIView!
	@IBOutlet var fifthView: UIView!

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

	@IBOutlet weak var fifth_last_constraint: NSLayoutConstraint!
	@IBOutlet weak var fifth_top_constraint: NSLayoutConstraint!
	@IBOutlet weak var fifth_middle_constraint: NSLayoutConstraint!
	@IBOutlet weak var fifth_bottom_constraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalWidth = Double(UIScreen.main.bounds.width * 2)
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height))
        firstView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        secondView.frame = CGRect(x: firstView.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        thirdView.frame = CGRect(x: firstView.bounds.width * 2, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//		fourthView.frame = CGRect(x: firstView.bounds.width * 3, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//		fifthView.frame = CGRect(x: firstView.bounds.width * 4, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

//		contentView.addSubview(fifthView)
//		contentView.addSubview(fourthView)
		contentView.addSubview(thirdView)
		contentView.addSubview(secondView)
		contentView.addSubview(firstView)
        
        scrollView.addSubview(contentView)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height)
        scrollView.isScrollEnabled = false;
        pageControl.alpha = 0;
		pageControl.currentPage = 0
        
        self.modifyingConstraints()
    }
    
    func modifyingConstraints() {
        
        first_top_constraint.constant /= (667/UIScreen.main.bounds.height)
        first_middle_constraint.constant /= (667/UIScreen.main.bounds.height)
        first_bottom_constraint.constant /= (667/UIScreen.main.bounds.height)
        
        second_top_constraint.constant /= (667/UIScreen.main.bounds.height)
        second_middle_constraint.constant /= (667/UIScreen.main.bounds.height)
        second_bottom_constraint.constant /= (667/UIScreen.main.bounds.height)
        
        third_top_constraint.constant /= (667/UIScreen.main.bounds.height)
        third_middle_constraint.constant /= (667/UIScreen.main.bounds.height)
        third_bottom_constraint.constant /= (667/UIScreen.main.bounds.height)
        
//		fourth_top_constraint.constant /= (667/UIScreen.main.bounds.height)
//		fourth_middle_constraint.constant /= (667/UIScreen.main.bounds.height)
//		fourth_bottom_constraint.constant /= (667/UIScreen.main.bounds.height)
//		
//		fifth_top_constraint.constant /= (667/UIScreen.main.bounds.height)
//		fifth_middle_constraint.constant /= (667/UIScreen.main.bounds.height)
//		fifth_bottom_constraint.constant /= (667/UIScreen.main.bounds.height)
//		fifth_last_constraint.constant /= (667/UIScreen.main.bounds.height)
    }
    
//MARK: IBAction methods
    @IBAction func beginButtonPressed(_ sender: RoundedBorderButton) {
        scrollView.isScrollEnabled = true
        UIView.animate(withDuration: 1, animations: {
            self.pageControl.alpha = 1
        })
        scrollView.setContentOffset(CGPoint(x: firstView.bounds.width, y: 0), animated: true)
//        pageControl.currentPage = 0

        //Removing the first page from the scrollview and reload
        Async.main(after: 0.5) {
            self.firstView.removeFromSuperview();
            self.totalWidth = Double(UIScreen.main.bounds.width * 2)
            self.contentView = UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height))
            self.secondView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            self.thirdView.frame = CGRect(x: self.firstView.bounds.width * 1,y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            self.fourthView.frame = CGRect(x: self.firstView.bounds.width * 2, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
//            self.fifthView.frame = CGRect(x: self.firstView.bounds.width * 3, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height)
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }

    }
    
    @IBAction func finishWalkthrough(_ sender: AnyObject) {
        UserDefaults.standard.set(true, forKey: "didFinishWalkthrough")
        UserDefaults.standard.synchronize()
        UIView.transition(with: AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            AppDelegate.sharedInstance().window?.rootViewController = Storyboards.Intro.instantiateViewController(withIdentifier: "LoginViewController")
            }, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 && pageControl.currentPage == 1 {
            return
        }
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        if (pageControl.currentPage == 1) {
            UIView.animate(withDuration: 0.3) {
                self.pageControl.alpha = 0;
            }
        } else{
            UIView.animate(withDuration: 0.3) {
                self.pageControl.alpha = 1;
            }
        }
    }
    
}
