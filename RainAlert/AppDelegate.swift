//
//  AppDelegate.swift
//  RainAlert
//
//  Created by segev perets on 05/12/2022.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

let isAuthorizeNotification = Notification.Name("isAuthorize")

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var gotLocationOnce = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        manager.delegate = self
        notificationCenter.delegate = self

        Task{ try! await notificationCenter.requestAuthorization(options:[.alert,.sound,.badge,.criticalAlert]) }
        
//        let item = UIApplicationShortcutItem(type: "deleteNotifications", localizedTitle: "Delete all notifications", localizedSubtitle: nil, icon: .init(systemImageName: "trash"))
//        application.shortcutItems = [item]
        
        return true
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        
        switch manager.authorizationStatus {
        case .notDetermined:
//            print("notDetermined")
            manager.requestAlwaysAuthorization()

        case .restricted, .denied:
//            print("restricted")
            manager.requestAlwaysAuthorization()
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            
        case .authorizedAlways, .authorizedWhenInUse:
//            print("authorizedAlways")
            manager.startUpdatingLocation()

        @unknown default:
            manager.requestAlwaysAuthorization()
//            print("default")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        if gotLocationOnce == false {
            procceedInOneSec(location)
            gotLocationOnce = true
        }
    }
    
    private func procceedInOneSec (_ location:CLLocation) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: isAuthorizeNotification, object: location)
        }
    }
    
    
//    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//        if shortcutItem.type == "deleteNotifications" {
//            NotificationViewModel.shared.removeAllNotification()
//        }
//    }





    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RainAlert")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

