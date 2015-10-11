//
//  AppDelegate.swift
//  Handler
//
//  Created by Oscar Swanros on 7/24/15.
//  Copyright (c) 2015 Handler, Inc. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import HandlerSDK
import Crashlytics
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	var sideMenu: SSASideMenu?
	var backgroundSessionCompletionHandler: (() -> Void)?
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		Mixpanel.sharedInstanceWithToken("a4ed41dc915c9b995e0f06836872def1", launchOptions: launchOptions)
		Twitter.sharedInstance().startWithConsumerKey("d6IKDpduuacAAHgtVydTvMo6t", consumerSecret: "tjaZYfuxDaEqY1RxLse0KvNzvCYPYpq57EgE0uawo2cuMzVoAE")

		APICommunicator.sharedInstance
		Fabric.with([Twitter.sharedInstance()])
		Fabric.with([Twitter.sharedInstance(), Crashlytics.self()])
		
		let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SideMenuViewController") as! SideMenuViewController
		let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavigationController")
		
		sideMenu = SSASideMenu(contentViewController: mainController, leftMenuViewController: menuViewController)
		sideMenu?.type = SSASideMenu.SSASideMenuType.Slip
		sideMenu?.contentViewInPortraitOffsetCenterX = 30
		sideMenu?.leftMenuRightInset = 30
		sideMenu?.menuViewControllerTransformation
		sideMenu?.statusBarStyle = SSASideMenu.SSAStatusBarStyle.Hidden
		if let _ = Twitter.sharedInstance().sessionStore.session() {
			window?.rootViewController = sideMenu
		}else{
			window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
		}
		window?.makeKeyAndVisible()
		
		
		let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(settings)
		UIApplication.sharedApplication().registerForRemoteNotifications()
		return true
	}
	
	func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
		print(url)
		HROAuthManager.handleIncomingAuthURL(url)
		return true
	}
	
	// MARK: Push
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		print(error)
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		NSUserDefaults.standardUserDefaults().setValue(deviceToken.hexadecimalString, forKey: "pushtoken")
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		if let id = userInfo["id"] as? String {
			
			APICommunicator.sharedInstance.getMessageWithCallback(id, callback: { (message, error) -> Void in
				guard let message = message else {
					print(error)
					completionHandler(UIBackgroundFetchResult.Failed)
					return
				}
				MailDatabaseManager.sharedInstance.storeMessage(message)
				UIApplication.sharedApplication().applicationIconBadgeNumber += 1
				let not = UILocalNotification()
				not.alertBody = message.content
				not.alertTitle = "New message from: @\(message.sender?.handle)"
				not.userInfo = ["messageID":message.id]
				
				UIApplication.sharedApplication().presentLocalNotificationNow(not)
				completionHandler(UIBackgroundFetchResult.NewData)
			})
		}else{
			completionHandler(UIBackgroundFetchResult.NoData)
		}
	}
	
	func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
		backgroundSessionCompletionHandler = completionHandler
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		if HROAuthManager.sharedManager.currentState == .WaitingForApproval {
			HROAuthManager.oAuthCancelled()
		}
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(application: UIApplication) {
		MailDatabaseManager.sharedInstance.saveContext()
	}
}

