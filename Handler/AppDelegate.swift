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
import NVActivityIndicatorView
import FirebaseRemoteConfig
import FirebaseAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var messageUpdateTimer : Timer?

	var window: UIWindow?
	lazy var sideMenu: SSASideMenu = {
		let menuViewController = Storyboards.Main.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
		let mainController = Storyboards.Main.instantiateViewController(withIdentifier: "MainNavigationController")
		let sideMenu = SSASideMenu(contentViewController: mainController, leftMenuViewController: menuViewController)
		sideMenu.type = SSASideMenu.SSASideMenuType.slip
		sideMenu.contentViewInPortraitOffsetCenterX = 50
		sideMenu.contentViewShadowEnabled = false
		sideMenu.leftMenuRightInset = 30
		sideMenu.fadeMenuView = true
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
		
        NVActivityIndicatorView.DEFAULT_TYPE = .lineScale
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.white
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 35)
		
		//Firebase
		FIRApp.configure()
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
		updateMessages()
		startMessageUpdateTimer()
		return true
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
		print(url)
//		HROAuthManager.handleIncomingAuthURL(url)
		return true
	}

	// MARK: Push

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error)
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		UserDefaults.standard.setValue(deviceToken.hexadecimalString, forKey: "pushtoken")
		Intercom.setDeviceToken(deviceToken)
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
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		cancelMessageUpdateTimer()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		startMessageUpdateTimer()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		cancelMessageUpdateTimer()
		CoreDataStack.shared.viewContext.trySave()
		CoreDataStack.shared.backgroundContext.trySave()		
	}


	func startMessageUpdateTimer() {
		messageUpdateTimer = Timer(timeInterval: TimeInterval(MAILBOX_REFRESH_INTERVAL), target: self, selector: #selector(AppDelegate.updateMessages), userInfo: nil, repeats: true)
	}

	func cancelMessageUpdateTimer() {
		messageUpdateTimer?.invalidate()
		messageUpdateTimer = nil
	}

	func updateMessages() {
		ConversationManager.updateConversations()
	}

	func loadInitialViewController() {
		if (UserDefaults.standard.bool(forKey: "didFinishWalkthrough") && !ENABLE_ONBOARDING_EVERY_RUN) {
			
			if let _ = AuthUtility.shared.accessToken {
				window?.rootViewController = sideMenu
				updateMessages()
				if let uid = AuthUtility.shared.user?.identifier {
					Intercom.registerUser(withUserId: uid)
				}
				AppAnalytics.fireLoginEvent()
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

