//
//  AppDelegate.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Init Crashlytics
        Fabric.with([Crashlytics()])
        
        // Init Data Manager managed object contexts
        DataManager.sharedInstance.setContexts(self.managedObjectContext!)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Timer.deleteInactiveTimers()

        if let activeVc = application.keyWindow?.rootViewController as? HomeViewController {
            activeVc.prepareForAppClosure()
        }
        
        self.clearNotifications()
        
        // queue up notifications for timer and warning intervals
        if let timer = Timer.getCurrentTimer() {
            if (Int(timer.duration) > 0 && !timer.isPaused.boolValue) {
                let projectedEndDate = timer.projectedEndDate()
                
                if (projectedEndDate.timeIntervalSinceNow > 0.0) {
                    let alarm = UILocalNotification()
                    alarm.fireDate = projectedEndDate
                    alarm.alertBody = "Timer is up!"
                    alarm.category = "BUTTR_ALERT_CATEGORY"
                    alarm.soundName = "butter_bark.wav"
                    UIApplication.sharedApplication().scheduleLocalNotification(alarm)
                    
                    for warning in timer.warnings {
                        let projectedFireDate = (warning as! Warning).projectedFireDate()
                        
                        if (projectedFireDate.timeIntervalSinceNow > 0.0) {
                            let alarm = UILocalNotification()
                            alarm.fireDate = projectedFireDate
                            alarm.alertBody = (warning as! Warning).alertMessage()
                            alarm.category = "BUTTR_ALERT_CATEGORY"
                            alarm.soundName = "butter_growl.wav"
                            UIApplication.sharedApplication().scheduleLocalNotification(alarm)
                        }
                    }
                }
                
            }
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.clearNotifications()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//        if (nil == notificationSettings.types) {
//            NSNotificationCenter.defaultCenter().postNotificationName("UserDeniedNotifications", object: self, userInfo: ["notificationSettings": notificationSettings])
//        }
        NSNotificationCenter.defaultCenter().postNotificationName("UserRegisteredNotifications", object: self, userInfo: ["notificationSettings": notificationSettings])
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.lkvsky.Buttr" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Buttr", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Buttr.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options:[NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    // MARK: Helper Methods
    
    func clearNotifications() {
        let notificationsOpt = UIApplication.sharedApplication().scheduledLocalNotifications
        
        if let notifications = notificationsOpt {
            if (notifications.count > 0) {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
        }
    }

}

