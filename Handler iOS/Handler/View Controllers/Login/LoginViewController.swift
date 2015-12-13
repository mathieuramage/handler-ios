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
    }
    
    @IBAction func registerButtonPressed(button: UIButton){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/signup")!)
    }
    
    @IBAction func loginButtonPressed(button: UIButton){
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            if let error = error {
                HRError(errorType: error).show()
                return
            }
            if let session = session {
                let twitter = Twitter.sharedInstance()
                let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:session)
                HRTwitterAuthManager.startAuth(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), callback: { (error, session) -> Void in
                    if let error = error {
                        if error.status == 401 {
                            // register new user
                            HandlerAPI.createUserWithCallback(oauthSigning.OAuthEchoHeadersToVerifyCredentials(), provider: "twitter", callback: { (user, error) -> Void in
                                if let error = error {
                                    error.show()
                                    return
                                }
                                if let _ = user {
                                    APICommunicator.sharedInstance.attemptRelogin()
                                    UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                        AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
                                        GreetingViewController.showWithHandle(user?.handle ?? "")
                                        }, completion: nil)
                                }
                            })
                        }else{
                            error.show()
                            return
                        }
                    } else {
                        if let _ = session {
                            UIView.transitionWithView(AppDelegate.sharedInstance().window!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                AppDelegate.sharedInstance().window?.rootViewController = AppDelegate.sharedInstance().sideMenu
                                GreetingViewController.show()
                                }, completion: nil)
                        }else{
                            let sessionError = HRError(title: "No session", status: 500, detail: "Current session couldn't be retrieved", displayMessage: "Current session couldn't be retrieved")
                            sessionError.show()
                        }
                    }
                })
            }else{
                let sessionError = HRError(title: "No session", status: 500, detail: "Current session couldn't be retrieved", displayMessage: "Current session couldn't be retrieved")
                sessionError.show()
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
