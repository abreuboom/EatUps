//
//  AppDelegate.swift
//  EatUps
//
//  Created by John Abreu on 7/11/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//
import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKLoginKit
import ChameleonFramework
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSServices.provideAPIKey("AIzaSyAFgY7q8av7Rpy5Diiwmd5XqJvITVStDM4")
        Database.database().isPersistenceEnabled = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // MARK: TODO: Check for logged in user
        if UserDefaults.standard.value(forKey: "uid") != nil {
            User.current?.id = Auth.auth().currentUser?.uid
            let loginVC = storyboard.instantiateViewController(withIdentifier: "selectLocationNavigation")
            self.window?.rootViewController = loginVC
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didLogout"), object: nil, queue: OperationQueue.main) { (Notification) in
            print("Logout notification received")
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.window?.rootViewController = loginVC
        }
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UINavigationBar.appearance().backgroundColor = HexColor(hexString: "FE3F67")
        UIApplication.shared.statusBarStyle = .lightContent
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self as MessagingDelegate
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            let state = UIApplication.shared.applicationState
            if state == .background {
                Database.database().reference().child("users/\(uid)/status").setValue("")
            }
            else if state == .active {
                Database.database().reference().child("users/\(uid)/status").setValue("online")
            }
            
//            APIManager.shared.checkForInvite { (success, eatupId) in
//                if success == true {
//                    APIManager.shared.ref.child("eatups/\(eatupId)").observeSingleEvent(of: .value, with: { (snapshot) in
//                        if let eatupDictionary = snapshot.value as? [String: Any] {
//                            let eatup = EatUp(dictionary: eatupDictionary)
//                            eatup.id = snapshot.key
//                            let inviterId = eatup.inviter
//                            APIManager.shared.getUser(uid: inviterId, completion: { (success, inviter) in
//
//                                let content = UNMutableNotificationContent()
//                                content.title = "\(inviter.name!) wants to eatup with you at \(eatup.place)"
//                                content.subtitle = "Do you know?"
//                                content.body = "Do you really know?"
//                                content.badge = 1
//
//                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//                                let request = UNNotificationRequest(identifier: "eatupInvite", content: content, trigger: trigger)
//
//                                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//                            })
//                        }
//                    })
//                }
//            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        print(userInfo)
        let gcmMessageIDKey = userInfo["gcm_message_id"] as? String
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey!] {
            print("Message ID: \(messageID)")
        }
        
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
    }
    
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
}
