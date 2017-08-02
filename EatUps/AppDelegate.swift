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
import FBSDKLoginKit
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
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

        //Chameleon.setGlobalThemeUsingPrimaryColor(HexColor(hexString: "FE3F67"), withSecondaryColor: ContrastColorOf(backgroundColor: HexColor(hexString: "FE3F67"), returnFlat: false),  andContentStyle: .contrast)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UINavigationBar.appearance().backgroundColor = HexColor(hexString: "FE3F67")
        UIApplication.shared.statusBarStyle = .lightContent
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert]
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification received")
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

