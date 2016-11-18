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

class LoginViewController: UIViewController {

	@IBOutlet weak var loadingView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let layer = CAGradientLayer.gradientLayerForBounds(UIScreen.main.bounds)
		self.view.layer.insertSublayer(layer, at: 0)
        if let twitterIcon = UIImage(named: "twitter_logo_white") {
            self.loginButton.setImage(twitterIcon, for: UIControlState())
        }
        self.setLoginButtonText()
        self.loginButton.imageEdgeInsets = UIEdgeInsetsMake(13,-20,13, -10)
        self.loginButton.titleEdgeInsets = UIEdgeInsetsMake(0,-50,0,20)
	}
    
    fileprivate func setLoginButtonText() {
        
        let boldAttribute = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!]
        let regularAttribute = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17.0)!]
        
        let loginAttributedString = NSAttributedString(string: "Log In with ", attributes: regularAttribute )
        let twitterAttributedString = NSAttributedString(string: "Twitter", attributes: boldAttribute)
        let buttonTitle =  NSMutableAttributedString()
        
        buttonTitle.append(loginAttributedString)
        buttonTitle.append(twitterAttributedString)
        buttonTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, buttonTitle.length))
        
        self.loginButton.setAttributedTitle(buttonTitle, for: UIControlState())
    }

	@IBAction func registerButtonPressed(_ button: UIButton){
		UIApplication.shared.openURL(URL(string: "https://twitter.com/signup")!)
	}

    @IBOutlet weak var loginButton: WhiteBorderButton!
    
	@IBAction func loginButtonPressed(_ button: UIButton){

		//Displaying loading view
		UIView.animate(withDuration: 1, animations: {
			self.loadingView.alpha = 1.0
		})

		Twitter.sharedInstance().logIn { session, error in
			if (session != nil) {
				print(session)
				print("signed in as \(session?.userName)");
			} else {
				print("error: \(error?.localizedDescription)");
			}

			if let session = session {

				let twitter = Twitter.sharedInstance()
				let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:session)

				print(oauthSigning.oAuthEchoHeadersToVerifyCredentials())

				var headers : [String : String] = [:]

				for (key, val) in oauthSigning.oAuthEchoHeadersToVerifyCredentials() {
					headers[String(describing: key)] = String(describing: val)
				}

//				let headers = oauthSigning.OAuthEchoHeadersToVerifyCredentials()

//				AuthUtility.getClientCredentials(headers: headers, callback: { (success, tempToken) in
//
//					guard let token = tempToken where success else {
//						return
//					}

					AuthUtility.getTokenAssertion(headers: headers, callback: { (success, accessToken) in

						guard let accessToken = accessToken, success else {
							return
						}

						AuthUtility.accessToken = accessToken
						
						// For best results, use a unique user_id if you have one.
						//Use Token or Id?
						Intercom.registerUser(withUserId: accessToken.token)

						UserOperations.getMe({ (success, user) in
							AuthUtility.user = user
	
							UIView.transition(with: AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
								AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
								GreetingViewController.showWithHandle(user?.handle ?? "", back: false)
								}, completion: nil)
						})

					})

//				})

			}
		}
	}

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}

}
