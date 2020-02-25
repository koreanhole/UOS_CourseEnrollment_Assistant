//
//  AppDelegate.swift
//  Search_Subject
//
//  Created by koreanhole on 2020/02/05.
//  Copyright © 2020 권순형. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        //시스템 tintcolor 정하는것
        //UIView.appearance().tintColor = UIColor.systemBlue
        
        //앱이 시작되면서 저장된 내 강의, 학과 목록 가져오기
        CourseData.sharedCourse.savedData = CourseData.loadFromFile()
        CourseData.sharedCourse.myDept_list = CourseData.loadListFromFile()
        
        //불러온 저장된 데이터를 파이어베이스에 업로드
        CourseData.updateUserData()
        Messaging.messaging().delegate = self
        
        
        UNUserNotificationCenter.current().delegate = self
        
        //알림센터에 모여있는 알림들 삭제
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
        //앱이 종료하면서 파이어베이스에 사용자데이터를 업로드 한다.
        CourseData.updateUserData()
        
        //내 강의, 학과를 디바이스에 저장한다.
        CourseData.saveListToFile(data: CourseData.sharedCourse.myDept_list)
        CourseData.saveToFile(data: CourseData.sharedCourse.savedData)
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
  }
}
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
}

