//
//  SpaceTalkApp.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/03/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging


class AppDelegate: NSObject, UIApplicationDelegate {
    
    //앱이 켜졌을때 발동
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      //firebase 설정
    FirebaseApp.configure()
      
      //원격 알림 등록
      if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self
          
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in }
          )
      }else {
          let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
      }
      
      application.registerForRemoteNotifications()
      
      //메시징 델리겟
      Messaging.messaging().delegate = self
      
      //앱이 열려있을 때도 푸시 설정
      UNUserNotificationCenter.current().delegate = self
      
    return true
  }
    
    //fcm 토큰이 등록 되었을 떄
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    //푸시메시지가 앱이 켜져 있을 때 나올 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("willPresent : userInfo : \(userInfo)")
        
        completionHandler([.banner, .sound, .badge])
    }
    
    //푸시 메시지를 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("willPresent : userInfo : \(userInfo)")
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
        
    // fcm 등록 토큰을 받았을때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - 파이어베이스 메시징 토큰을 받음.")
        print("AppDelegate - 파이어베이스 메시징 토큰 : \(String(describing: fcmToken))")
    }
}


@main
struct SpaceTalkApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(LoginViewModel()).environmentObject(FirestoreViewModel())
        }
    }
}



//var body: some Scene {
//    WindowGroup {
//      NavigationView {
//        ContentView()
//      }
//    }
//  }
