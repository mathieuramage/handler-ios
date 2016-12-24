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
import Crashlytics
import Async
import Instabug
import Intercom
import FirebaseRemoteConfig
import FirebaseAnalytics
import FirebaseDynamicLinks



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	let customURLScheme = "dlscheme"

	var messageUpdateTimer : Timer?

	var window: UIWindow?
	lazy var sideMenu: SSASideMenu = {
		let menuViewController = Storyboards.Main.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
		let mainController = Storyboards.Main.instantiateViewController(withIdentifier: "MainNavigationController")
		let sideMenu = SSASideMenu(contentViewController: mainController, leftMenuViewController: menuViewController)
		sideMenu.type = SSASideMenu.SSASideMenuType.slip
		sideMenu.contentViewInPortraitOffsetCenterX = 30
		sideMenu.leftMenuRightInset = 30
		sideMenu.statusBarStyle = SSASideMenu.SSAStatusBarStyle.hidden
		return sideMenu
	}()

	var backgroundSessionCompletionHandler: (() -> Void)?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		Twitter.sharedInstance().start(withConsumerKey: Config.Twitter.consumerKey, consumerSecret: Config.Twitter.consumerSecret)
		Fabric.with([Twitter.sharedInstance(), Crashlytics.self()])
		Instabug.start(withToken: Config.Instabug.apiToken, invocationEvent: .shake)
		Instabug.setShakingThresholdForiPhone(1.2, foriPad: 0.5)
		Intercom.setApiKey(Config.Intercom.apiKey, forAppId: Config.Intercom.appId)
//		UserTwitterStatusManager.startUpdating() TODO : Do this properly with the new API code
		UIToolbar.appearance().tintColor = UIColor(rgba: HexCodes.lightBlue)
		UITextField.appearance().tintColor = UIColor(rgba: HexCodes.lightBlue)
		UITextView.appearance().tintColor = UIColor(rgba: HexCodes.lightBlue)
		UIImageView.appearance().clipsToBounds = true

		//Firebase
		FIRApp.configure()
		FIROptions.default().deepLinkURLScheme = self.customURLScheme
		let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
		let remoteConfig = Config.Firebase.RemoteConfig.instance
		remoteConfig.configSettings = remoteConfigSettings!
		remoteConfig.setDefaults(Config.Firebase.RemoteConfig.defaultParams)
		remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
			if status == .success {
				print("Remote config parameters successfully fetched!")
				remoteConfig.activateFetched()
			} else {
				print("Remote Config not fetched")
				print("Error \(error!.localizedDescription)")
			}
		}
		
		loadInitialViewController()

		let settings = UIUserNotificationSettings(types: [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert], categories: nil)
		UIApplication.shared.registerUserNotificationSettings(settings)
		UIApplication.shared.registerForRemoteNotifications()
		UIApplication.shared.applicationIconBadgeNumber = 0
		startMessageUpdateTimer()
		return true
	}
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		print(url)
		//		HROAuthManager.handleIncomingAuthURL(url)
		
		//Deep Links
		// Handle the deep link. For example, show the deep-linked content or
		// apply a promotional offer to the user's account.
		// ...
		let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
		if let link = dynamicLink {
			if let action = link.url?.queryItems?["action"] {
				switch action {
					case Config.Firebase.DynamicLinks.Actions.compose:
					break
					default:
					break
				}
			}
			return true
		}
		
		return false
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
		return application(app, open: url, sourceApplication: nil, annotation: [:])
	}
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
			return false
		}
		let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
			// ...
		}
		
		return handled
	}


	// MARK: Push

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error)
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		UserDefaults.standard.setValue(deviceToken.hexadecimalString, forKey: "pushtoken")
		// TODO upcoming push notifcation task
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

//		if let id = userInfo["id"] as? String {
//
//			APICommunicator.sharedInstance.getMessageWithCallback(id, callback: { (message, error) -> Void in
//				guard let message = message else {
//					print(error)
//					completionHandler(UIBackgroundFetchResult.Failed)
//					return
//				}
//				// OTTODO: Implement store message
////				DatabaseManager.sharedInstance.storeMessage(message)
//				UIApplication.sharedApplication().applicationIconBadgeNumber += 1
//				let not = UILocalNotification()
//				not.alertBody = message.content
//				not.alertTitle = "New message from: @\(message.sender?.handle)"
//				not.userInfo = ["messageID":message.id]
//
//				UIApplication.sharedApplication().presentLocalNotificationNow(not)
//				completionHandler(UIBackgroundFetchResult.NewData)
//			})
//		} else {
//			completionHandler(UIBackgroundFetchResult.NoData)
//		}
	}

	func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
		backgroundSessionCompletionHandler = completionHandler
	}

	func applicationWillResignActive(_ application: UIApplication) {
		cancelMessageUpdateTimer()
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		cancelMessageUpdateTimer()
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		startMessageUpdateTimer()
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		cancelMessageUpdateTimer()
		DatabaseManager.sharedInstance.mainManagedContext.saveRecursively()
	}


	func startMessageUpdateTimer() {
		messageUpdateTimer = Timer(timeInterval: TimeInterval(MAILBOX_REFRESH_INTERVAL), target: self, selector: #selector(AppDelegate.updateMessages), userInfo: nil, repeats: true)
	}

	func cancelMessageUpdateTimer() {
		messageUpdateTimer?.invalidate()
		messageUpdateTimer = nil
	}

	func updateMessages() {
//		APICommunicator.sharedInstance.fetchNewMessagesWithCompletion { (error) -> Void in
//			Async.main(block: { () -> Void in
//				guard let error = error else {
//					return
//				}
//				error.show()
//			})
//		}
	}

	func loadInitialViewController() {
		if (UserDefaults.standard.bool(forKey: "didFinishWalkthrough") && !ENABLE_ONBOARDING_EVERY_RUN) {
			
			if let _ = AuthUtility.accessToken {
				window?.rootViewController = sideMenu
				if let uid = UserDefaults.standard.string(forKey: Config.UserDefaults.uidKey) {
					Intercom.registerUser(withUserId: uid)
				}
			}else{
				window?.rootViewController = Storyboards.Intro.instantiateViewController(withIdentifier: "LoginViewController")
			}
		}else{
			window?.rootViewController = IntroViewController(nibName: "IntroView", bundle: nil)
		}
		window?.makeKeyAndVisible()
	}
}

// MARK: Utilities

extension AppDelegate {
	static func sharedInstance()->AppDelegate{
		return UIApplication.shared.delegate as! AppDelegate
	}
}

