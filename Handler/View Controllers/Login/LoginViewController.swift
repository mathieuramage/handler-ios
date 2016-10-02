//
//  LoginViewController.swift
//  Handler
//
//  Created by Christian Praiss on 19/09/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
//

import UIKit
import TwitterKit
import KeychainAccess
import HandleriOSSDK

class LoginViewController: UIViewController {

	@IBOutlet weak var loadingView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let layer = CAGradientLayer.gradientLayerForBounds(UIScreen.mainScreen().bounds)
		self.view.layer.insertSublayer(layer, atIndex: 0)
        if let twitterIcon = UIImage(named: "twitter_logo_white") {
            self.loginButton.setImage(twitterIcon, forState: .Normal)
        }
        self.setLoginButtonText()
        self.loginButton.imageEdgeInsets = UIEdgeInsetsMake(13,-20,13, -10)
        self.loginButton.titleEdgeInsets = UIEdgeInsetsMake(0,-50,0,20)
	}
    
    private func setLoginButtonText() {
        
        let boldAttribute = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!]
        let regularAttribute = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17.0)!]
        
        let loginAttributedString = NSAttributedString(string: "Log In with ", attributes: regularAttribute )
        let twitterAttributedString = NSAttributedString(string: "Twitter", attributes: boldAttribute)
        let buttonTitle =  NSMutableAttributedString()
        
        buttonTitle.appendAttributedString(loginAttributedString)
        buttonTitle.appendAttributedString(twitterAttributedString)
        buttonTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, buttonTitle.length))
        
        self.loginButton.setAttributedTitle(buttonTitle, forState: .Normal)
    }

	@IBAction func registerButtonPressed(button: UIButton){
		UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/signup")!)
	}

    @IBOutlet weak var loginButton: WhiteBorderButton!
    
	@IBAction func loginButtonPressed(button: UIButton){

		//Displaying loading view
		UIView.animateWithDuration(1, animations: {
			self.loadingView.alpha = 1.0
		})


		Twitter.sharedInstance().logInWithCompletion { session, error in
			if (session != nil) {
				print(session)
				print("signed in as \(session?.userName)");
			} else {
				print("error: \(error?.localizedDescription)");
			}

			if let session = session {

				let twitter = Twitter.sharedInstance()
				let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:session)

				print(oauthSigning.OAuthEchoHeadersToVerifyCredentials())

				var headers : [String : String] = [:]

				for (key, val) in oauthSigning.OAuthEchoHeadersToVerifyCredentials() {
					headers[String(key)] = String(val)
				}

//				let headers = oauthSigning.OAuthEchoHeadersToVerifyCredentials()

//				AuthUtility.getClientCredentials(headers: headers, callback: { (success, tempToken) in
//
//					guard let token = tempToken where success else {
//						return
//					}

					AuthUtility.getTokenAssertion(headers: headers, callback: { (success, accessToken) in

						guard let accessToken = accessToken where success else {
							return
						}

						AuthUtility.accessToken = accessToken

						UserOperations.getMe({ (success, user) in
							AuthUtility.user = user

							UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
								AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
								GreetingViewController.showWithHandle(user?.handle ?? "", back: false)
								}, completion: nil)
						})

					})

//				})

			}
		}
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

}
