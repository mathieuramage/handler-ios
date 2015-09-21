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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

}
