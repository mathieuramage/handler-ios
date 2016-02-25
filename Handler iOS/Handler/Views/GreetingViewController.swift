//
//  GreetingViewController.swift
//  Handler
//
//  Created by Christian Praiß on 12/13/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Async
import HandlerSDK
import Kingfisher

class GreetingViewController: UIViewController, UIViewControllerShow {
    
    @IBOutlet weak var profileImageView: WhiteBorderImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var continueButton: WhiteBorderButton!
    
    //GreetingCard view
    static var contactCard = GreetingViewController(nibName: "GreetingViewController", bundle: nil)
    var window: UIWindow?
    
    var welcomeBack: Bool = false
    var handle: String? {
        didSet {
            if let handle = handle {
                getDataWithHandle(handle)
            }
        }
    }
    
    var user: User? {
        didSet {
            if let user = user, let handle = user.handle {
                getDataWithHandle(handle)
            }
        }
    }
    
    func getDataWithHandle(handle: String){
        TwitterAPICommunicator.getAccountInfoForTwitterUser(handle, callback: { (json, error) -> Void in
            guard let json = json else {
                print(error)
                return
            }
            Async.main {
                if !self.welcomeBack {
                    self.handleLabel.text = "Welcome @\(json["screen_name"].stringValue)"
                }else{
                    self.handleLabel.text = "Welcome back @\(json["screen_name"].stringValue)"
                }
                self.continueButton.borderColor = UIColor(rgba: HexCodes.lightBlue)
                self.continueButton.setTitleColor(UIColor(rgba: HexCodes.lightBlue), forState: .Normal)
                
                if let urlString = json["profile_banner_url"].string {
                    let bannerURLString = urlString + "/600x200"
                    if let url = NSURL(string: bannerURLString){
                        self.bannerImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "twitter_default"), optionsInfo: [.Transition(ImageTransition.Fade(0.3))])
                    }
                }
                if PRINT_TWITTER_USERDATA_RESPONSE{
                    print(json)
                }
                
                if let urlString = json["profile_image_url"].string, let url = NSURL(string: urlString.stringByReplacingOccurrencesOfString("_normal", withString: "")){
                    self.profileImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "twitter_default"), optionsInfo: [.Transition(ImageTransition.Fade(0.3))])
                }
                self.continueButton.userInteractionEnabled = true
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    GreetingViewController.contactCard.view.alpha = 1
                    self.view.layoutSubviews()
                })
                
            }
        })
    }
    
    class func show(back: Bool = false) {
        contactCard.welcomeBack = back
        NSNotificationCenter.defaultCenter().addObserver(contactCard, selector: "updateView", name: HRCurrentUserDidSetNotification, object: nil)
        contactCard.show()
        contactCard.view.alpha = 0;
    }
    
    class func showWithHandle(handle: String, back: Bool = false){
        contactCard.welcomeBack = back
        contactCard.handle = handle
        contactCard.show()
        contactCard.view.alpha = 0;
    }
    
    func updateView(){
        if let user = HRUserSessionManager.sharedManager.currentUser {
            getDataWithHandle(user.handle)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.borderColor = UIColor(rgba: HexCodes.lightGray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismissPressed(sender: AnyObject?) {
        dismiss()
    }
    
    @IBAction func dismiss(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.window?.alpha = 0
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            }) { (success) -> Void in
                self.window = nil
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

