//
//  GreetingViewController.swift
//  Handler
//
//  Created by Christian Praiß on 12/13/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import Async
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
            if let user = user {
                getDataWithHandle(user.handle)
            }
        }
    }
    
    func getDataWithHandle(_ handle: String){
        TwitterAPIOperations.getAccountInfoForTwitterUser(handle, callback: { (json, error) -> Void in
            guard let json = json else {
                if let error = error {
                    print(error)
                }
                return
            }
            Async.main {
                if !self.welcomeBack {
                    self.handleLabel.text = "Welcome @\(json["screen_name"].stringValue)"
                } else {
                    self.handleLabel.text = "Welcome back @\(json["screen_name"].stringValue)"
                }
                self.continueButton.borderColor = UIColor(rgba: HexCodes.lightBlue)
                self.continueButton.setTitleColor(UIColor(rgba: HexCodes.lightBlue), for: .normal)
                
                if let urlString = json["profile_banner_url"].string, let url = URL(string: urlString + DEFAULT_BANNER_RESOLUTION){
                    
                    self.bannerImageView.kf.setImage(with: url, placeholder: UIImage.randomGhostImage(), options: [.transition(ImageTransition.fade(0.3))], progressBlock: nil, completionHandler: nil)
                }
                if PRINT_TWITTER_USERDATA_RESPONSE{
                    print(json)
                }
                
                if let urlString = json["profile_image_url"].string, let url = URL(string:urlString.replacingOccurrences(of: "_normal", with: "")){
                    self.profileImageView.kf.setImage(with: url, placeholder: UIImage(named:"twitter_default"), options: [.transition(ImageTransition.fade(0.3))], progressBlock: nil, completionHandler: nil)
                }
                self.continueButton.isUserInteractionEnabled = true
                
                UIView.animate(withDuration: 0.3, animations: {
                    GreetingViewController.contactCard.view.alpha = 1
                    self.view.layoutSubviews()
                })
                
            }
        })
    }
    
    class func show(_ back: Bool = false) {
        contactCard.welcomeBack = back
        NotificationCenter.default.addObserver(contactCard, selector: #selector(GreetingViewController.updateView), name: NSNotification.Name(rawValue: HRCurrentUserDidSetNotification), object: nil)
        contactCard.show()
        contactCard.view.alpha = 0;
    }
    
    class func showWithHandle(_ handle: String, back: Bool = false){
        contactCard.welcomeBack = back
        contactCard.handle = handle
        contactCard.show()
        contactCard.view.alpha = 0;
    }
    
    func updateView() {
        if let user = AuthUtility.shared.user {
            getDataWithHandle(user.handle)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.borderColor = UIColor(rgba: HexCodes.lightGray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismissPressed(_ sender: AnyObject?) {
        dismiss()
    }
    
    @IBAction func dismiss() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.window?.alpha = 0
            UIApplication.shared.statusBarStyle = .lightContent
        }, completion: { (success) -> Void in
            self.window = nil
        })
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

