//
//  AppDelegate.swift
//  HeartBeat
//
//  Created by inailuy on 6/15/16.
//  Copyright © 2016 Mxtapes. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import CloudKit
import AccountKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let swipeBetweenVC: YZSwipeBetweenViewController = YZSwipeBetweenViewController()
    static let sharedInstance = AppDelegate()
    var accountKit: AKFAccountKit!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Register FacebookSDK
        //FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Register for push notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        accountKit = AKFAccountKit(responseType: .AccessToken)
        accountKit.requestAccount{(account, error) -> Void in }
        
        //setting Up SnapChatUI
        setUpStoryboardUI()
        UserSettings.sharedInstance.loadInstances()
        Bluetooth.sharedInstance.load()
        if UserSettings.sharedInstance.userEnabledHealth {
            Health.sharedInstance.askPermissionForHealth()
        }
        
        DataController.sharedInstance.load()
        //Navigation Appearance
        let barButtonAppearance = [NSFontAttributeName : UIFont(name: helveticaLightFont, size: 18)!]
        let navBarApearance = [NSFontAttributeName : UIFont(name: helveticaLightFont, size: 24)!,
                               NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAppearance, forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = navBarApearance

        return true
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
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    /*
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    */
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "inailuy.HeartBeat" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("HeartBeat", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    // MARK: - Misc
    func setUpStoryboardUI() {
        swipeBetweenVC.initialViewControllerIndex = 1
        swipeBetweenVC.scrollView.alwaysBounceVertical = false
        //creating ViewControllers and NavigationsControllers
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let historyVC = storyBoard.instantiateViewControllerWithIdentifier("historyID")
        let mainVC = storyBoard.instantiateViewControllerWithIdentifier("mainID")
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("settingsID")
        let nav1 = UINavigationController(rootViewController: historyVC)
        let nav2 = UINavigationController(rootViewController: mainVC)
        let nav3 = UINavigationController(rootViewController: settingsVC)
        swipeBetweenVC.viewControllers = [nav1,nav2,nav3]
        //add everything into UIWindow
        let frame = UIScreen.mainScreen().bounds
        window?.frame = frame
        window!.rootViewController = swipeBetweenVC
        window!.makeKeyAndVisible()
    }
    
    // MARK: - Notifications
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        if ckNotification.notificationType == .Query,
            let queryNotification = ckNotification as? CKQueryNotification
        {
            if queryNotification.queryNotificationReason == .RecordCreated {
                CloudKit.sharedInstance.queryPrivateDatabaseWithRecordID(queryNotification.recordID!)
            } else if queryNotification.queryNotificationReason == .RecordDeleted {
                // delete
            } else if queryNotification.queryNotificationReason == .RecordUpdated {
                // updated
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //print(error.localizedDescription)
    }
}

