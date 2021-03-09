//
//  AppDelegate.swift
//  Campus Online
//
//  Created by mahsun abuzeyitoğlu on 20.08.2020.
//  Copyright © 2020 mahsun abuzeyitoğlu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseMessaging
import Firebase
import SDWebImage
import GoogleMobileAds
import UserNotifications
import FirebaseInstanceID

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    let gcmMessageIDKey = "id_msgges"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = SplashScreen()
       
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        registerForPushNotifications()
               
               if #available(iOS 10.0, *) {
                   // For iOS 10 display notification (sent via APNS)
                   UNUserNotificationCenter.current().delegate = self
                   
                   let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                   UNUserNotificationCenter.current().requestAuthorization(
                       options: authOptions,
                       completionHandler: {_, _ in })
               } else {
                   let settings: UIUserNotificationSettings =
                       UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                   application.registerUserNotificationSettings(settings)
               }
               
               Messaging.messaging().delegate = self
               
               application.registerForRemoteNotifications()
     
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
           UIApplication.shared.applicationIconBadgeNumber = 0
       }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
      
    }
    func registerForPushNotifications() {
          UNUserNotificationCenter.current()
              .requestAuthorization(options: [.alert, .sound, .badge]) {(granted, error) in
                  print("Permission granted: \(granted)")
          }
      }
    
    // MARK: UISceneSession Lifecycle
       func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
           // If you are receiving a notification message while your app is in the background,
           // this callback will not be fired till the user taps on the notification launching the application.
           // TODO: Handle data of notification
           
           // With swizzling disabled you must let Messaging know about the message, for Analytics
           // Messaging.messaging().appDidReceiveMessage(userInfo)
           
           // Print message ID.
           if let messageID = userInfo[gcmMessageIDKey] {
               print("Message ID: \(messageID)")
           }
           
           // Print full message.
           print(userInfo)
       }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // If you are receiving a notification message while your app is in the background,
            // this callback will not be fired till the user taps on the notification launching the application.
            // TODO: Handle data of notification
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            // Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
            
            completionHandler(UIBackgroundFetchResult.newData)
        }

}
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
     
        guard let token = fcmToken else { return }
        print("Firebase registration token: \(token)")
        let dataDict:[String: String] = ["token": token]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        if Auth.auth().currentUser?.uid == nil {
            return
        }
        else{
            let db = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
            db.setData(["tokenID" : token] as [String : Any], merge: true)
        }
        
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        'instanceID(handler:)' is deprecated: Use `Installations.installationID(completion:)` to get the app instance identifier instead. Use `Messaging.token(completion:)` to get FCM registration token instead.
        Messaging.messaging().token { token, error in
            if error != nil  {
                
            }else{
                guard let token = token else { return }
                print("Remote instance ID token: \(token)")
                guard let user = Auth.auth().currentUser else {
                   return
                }
                
                let db = Firestore.firestore().collection("user")
                    .document(user.uid)
                db.setData(["tokenID":token] , merge: true)
            }
            application.applicationIconBadgeNumber = 0
        }
        
    }
}
@available(iOS 10, *)

extension AppDelegate : UNUserNotificationCenterDelegate {
    
      // Receive displayed notifications for iOS 10 devices.
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          let userInfo = notification.request.content.userInfo
          
          // With swizzling disabled you must let Messaging know about the message, for Analytics
          // Messaging.messaging().appDidReceiveMessage(userInfo)
          
          // Print message ID.
          if let messageID = userInfo[gcmMessageIDKey] {
              print("Message ID: \(messageID)")
          }
          
          // Print full message.
          print(userInfo)
          
          // Change this to your preferred presentation option
          completionHandler([[.alert, .sound , .badge]])
      }
      
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
          let userInfo = response.notification.request.content.userInfo
          // Print message ID.
          if let messageID = userInfo[gcmMessageIDKey] {
              print("Message ID: \(messageID)")
          }
          
          // Print full message.
          print(userInfo)
          
          completionHandler()
      }
}
