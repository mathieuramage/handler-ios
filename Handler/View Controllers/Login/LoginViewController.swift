//
//  LoginViewController.swift
//  Handler
//
//  Created by Christian Praiss on 19/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import TwitterKit
import Intercom
import NVActivityIndicatorView

class LoginViewController: UIViewController,NVActivityIndicatorViewable {
    
    var activityData : ActivityData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let twitterIcon = UIImage(named: "twitter_icon_blue") {
            self.loginButton.setImage(twitterIcon, for: UIControlState())
        }
        self.setLoginButtonText()
        self.loginButton.imageEdgeInsets = UIEdgeInsetsMake(13,-20,13, 32)
        self.loginButton.titleEdgeInsets = UIEdgeInsetsMake(0,-50,0,23)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let activityData = activityData {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    fileprivate func setLoginButtonText() {
        
        let boldAttribute = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!]
        let regularAttribute = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17.0)!]
        
        let loginAttributedString = NSAttributedString(string: "Log In with ", attributes: regularAttribute )
        let twitterAttributedString = NSAttributedString(string: "Twitter", attributes: boldAttribute)
        let buttonTitle =  NSMutableAttributedString()
        
        buttonTitle.append(loginAttributedString)
        buttonTitle.append(twitterAttributedString)
        buttonTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor(colorLiteralRed: 85/255, green: 170/255, blue: 236/255, alpha: 1.0), range: NSMakeRange(0, buttonTitle.length))
        
        self.loginButton.setAttributedTitle(buttonTitle, for: UIControlState())
    }
    
    @IBAction func registerButtonPressed(_ button: UIButton){
        UIApplication.shared.openURL(URL(string: "https://twitter.com/signup")!)
    }
    
    @IBOutlet weak var loginButton: WhiteBorderButton!
	
    @IBAction func loginButtonPressed(_ button: UIButton){

        Twitter.sharedInstance().logIn { session, error in
            if let session = session {
                let twitter = Twitter.sharedInstance()
                let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:session)

                print(oauthSigning.oAuthEchoHeadersToVerifyCredentials())

                var headers : [String : String] = [:]

                for (key, val) in oauthSigning.oAuthEchoHeadersToVerifyCredentials() {
                    headers[String(describing: key)] = String(describing: val)
                }

                AuthUtility.getTokenAssertion(headers: headers, callback: { (success, accessToken) in

                    guard let accessToken = accessToken, success else {
                        AuthUtility.getClientCredentials(headers: headers, callback: { (success, tempToken) in

                            guard let tempToken = tempToken, success else {
                                return
                            }
                            headers["Authorization"] = tempToken.type + " " + tempToken.token
                            AuthUtility.createUser(headers: headers, callback: { (success, userData) in
                                self.handleAccessTokenSuccessWith(accessToken: tempToken)
                            })
                        })

                        return
                    }
                    self.handleAccessTokenSuccessWith(accessToken: accessToken)
                })
                
            }
        }
    }

    func handleAccessTokenSuccessWith(accessToken: AccessToken) {
        AuthUtility.accessToken = accessToken

        AppAnalytics.fireLoginEvent()

        UserOperations.getMe({ (success, userData) in
            AuthUtility.user = UserDao.updateOrCreateUser(userData: userData!)
            let user = AuthUtility.user
            if let uid = user?.handle {
                UserDefaults.standard.set(uid, forKey: Config.UserDefaults.uidKey)
                Intercom.registerUser(withUserId: uid)
            }

            UIView.transition(with: AppDelegate.sharedInstance().window!, duration: 0.5, options:
                UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
                GreetingViewController.showWithHandle(user?.handle ?? "", back: false)
            }, completion: nil)
        })
    }

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
}
