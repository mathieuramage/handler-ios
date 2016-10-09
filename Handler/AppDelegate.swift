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
import HandleriOSSDK
import Crashlytics
import Async


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var messageUpdateTimer : NSTimer?

	var window: UIWindow?
	lazy var sideMenu: SSASideMenu = {
		let menuViewController = Storyboards.Main.instantiateViewControllerWithIdentifier("SideMenuViewController") as! SideMenuViewController
		let mainController = Storyboards.Main.instantiateViewControllerWithIdentifier("MainNavigationController")
		let sideMenu = SSASideMenu(contentViewController: mainController, leftMenuViewController: menuViewController)
		sideMenu.type = SSASideMenu.SSASideMenuType.Slip
		sideMenu.contentViewInPortraitOffsetCenterX = 30
		sideMenu.leftMenuRightInset = 30
		sideMenu.statusBarStyle = SSASideMenu.SSAStatusBarStyle.Hidden
		return sideMenu
	}()

	var backgroundSessionCompletionHandler: (() -> Void)?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		HandlerAPI.startWithClientId("9c3594fbb153aec6c70477a66229bca7786b7b7b5beb6b2c68c2997ab7ca1e4f", clientSecret : "58614156d6144ed0fd76a0cad80e00cfb5bd2fc33ec1e348fd8d6ffa18d66007")


		Twitter.sharedInstance().startWithConsumerKey(Config.Twitter.consumerKey, consumerSecret: Config.Twitter.consumerSecret)
		Fabric.with([Twitter.sharedInstance(), Crashlytics.self()])
		APICommunicator.sharedInstance.start()
		UserTwitterStatusManager.startUpdating()
		UIToolbar.appearance().tintColor = UIColor(rgba: HexCodes.lightBlue)
		UITextField.appearance().tintColor = UIColor(rgba: HexCodes.lightBlue)
		UITextView.appearance().tintColor = UIColor(rgba: HexCodes.lightBlue)
		UIImageView.appearance().clipsToBounds = true
		if (NSUserDefaults.standardUserDefaults().boolForKey("didFinishWalkthrough") && !ENABLE_ONBOARDING_EVERY_RUN) {
			if let _ = Twitter.sharedInstance().sessionStore.session() {
				APICommunicator.sharedInstance.attemptRelogin()
				window?.rootViewController = sideMenu
			} else {
				window?.rootViewController = Storyboards.Intro.instantiateViewControllerWithIdentifier("LoginViewController")
			}
		} else {
			window?.rootViewController = IntroViewController(nibName: "IntroView", bundle: nil)
		}


		window?.makeKeyAndVisible()

		let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(settings)
		UIApplication.sharedApplication().registerForRemoteNotifications()
		UIApplication.sharedApplication().applicationIconBadgeNumber = 0
		startMessageUpdateTimer()
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
		APICommunicator.sharedInstance.uploadToken()
	}

	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

		if let id = userInfo["id"] as? String {

			APICommunicator.sharedInstance.getMessageWithCallback(id, callback: { (message, error) -> Void in
				guard let message = message else {
					print(error)
					completionHandler(UIBackgroundFetchResult.Failed)
					return
				}
				// OTTODO: Implement store message
//				DatabaseManager.sharedInstance.storeMessage(message)
				UIApplication.sharedApplication().applicationIconBadgeNumber += 1
				let not = UILocalNotification()
				not.alertBody = message.content
				not.alertTitle = "New message from: @\(message.sender?.handle)"
				not.userInfo = ["messageID":message.id]

				UIApplication.sharedApplication().presentLocalNotificationNow(not)
				completionHandler(UIBackgroundFetchResult.NewData)
			})
		} else {
			completionHandler(UIBackgroundFetchResult.NoData)
		}
	}

	func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
		backgroundSessionCompletionHandler = completionHandler
	}

	func applicationWillResignActive(application: UIApplication) {
		cancelMessageUpdateTimer()
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		cancelMessageUpdateTimer()
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		startMessageUpdateTimer()
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		cancelMessageUpdateTimer()
		DatabaseManager.sharedInstance.mainManagedContext.saveRecursively()
	}


	func startMessageUpdateTimer() {
		messageUpdateTimer = NSTimer(timeInterval: NSTimeInterval(MAILBOX_REFRESH_INTERVAL), target: self, selector: #selector(AppDelegate.updateMessages), userInfo: nil, repeats: true)
	}

	func cancelMessageUpdateTimer() {
		messageUpdateTimer?.invalidate()
		messageUpdateTimer = nil
	}

	func updateMessages() {
		APICommunicator.sharedInstance.fetchNewMessagesWithCompletion { (error) -> Void in
			Async.main(block: { () -> Void in
				guard let error = error else {
					return
				}
				error.show()
			})
		}
	}
}

// MARK: Utilities

extension AppDelegate {
	static func sharedInstance()->AppDelegate{
		return UIApplication.sharedApplication().delegate as! AppDelegate
	}
}

