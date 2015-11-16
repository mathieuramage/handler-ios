//
//  LoginViewController.swift
//  Handler
//
//  Created by Christian Praiss on 19/09/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

import UIKit
import TwitterKit
import KeychainAccess
import HandlerSDK

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = CAGradientLayer.gradientLayerForBounds(UIScreen.mainScreen().bounds)
        self.view.layer.insertSublayer(layer, atIndex: 0)
        
        
        /*  Twitter oauth snippet after session was created
        
        let twitter = Twitter.sharedInstance()
        let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:session)
        HRTwitterAuthManager.startAuth(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), callback: { (error) -> Void in
        if let error = error {
        var errorPopup = ErrorPopupViewController()
        errorPopup.error = error
        errorPopup.show()
        return
        }
        
        UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
        AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
        }, completion: nil)
        })
        
        */
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
