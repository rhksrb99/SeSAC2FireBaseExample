//
//  AppDelegate.swift
//  SeSAC2FireBaseExample
//
//  Created by 박관규 on 2022/10/05.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIViewController.swizzleMethod()
        
        aboutRealmMigration()
        
        FirebaseApp.configure()
        
        // 원격 알림 시스템에 앱을 등록
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        // 메시지 대리자 설정
        Messaging.messaging().delegate = self
        
        return true
    }

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


}

extension AppDelegate {
    
    func aboutRealmMigration() {
        // deleteRealmIfMigrationNeeded: 마이그레이션이 필요한 경우 기존 렘 삭제 ( Realm Browser 닫고 다시 열기!
        // 버전에 들어가는건 가장 최신 버전이 들어간다.
//        let config = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        let config = Realm.Configuration(schemaVersion: 6) { migration, oldSchemaVersion in
            
            // 컬럼, 테이블 단순 추가 삭제의 경우엔 별도로 코드가 필요하지않다
            if oldSchemaVersion < 1 {
                
            }
            
            if oldSchemaVersion < 2 {
                
            }
            
            if oldSchemaVersion < 3 {
                migration.renameProperty(onType: Todo.className(), from: "importance", to: "favorite")
            }
            
            if oldSchemaVersion < 4 {
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let new = newObject else { return }
                    guard let old = oldObject else { return }
                    
                    new["userDecription"] = "Hello \(old["title"]!) 의 중요도는 \(old["favorite"]!)입니다."
                    
//                    new["title"] =
                }
            }
            
            if oldSchemaVersion < 5 {
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let new = newObject else { return }
                    new["count"] = 100
                }
            }
            
            if oldSchemaVersion < 6 {
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let new = newObject else { return }
                    guard let old = oldObject else { return }
                    
                    // new, old 가 옵셔널이라면 ?? 1.0 혹은 2.0
                    new["favorite"] = old["favorite"]
                    
                    
                }
            }
            
        }
        
        Realm.Configuration.defaultConfiguration = config
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 포그라운드 알림 수신 : 로컬/푸시 알림
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Setting 화면에 있다면 포그라운드 푸시 띄우지 않도록
        guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
        
        if viewController is SettingViewController {
            completionHandler([])
        } else {
            // .badge, .list: iOS14+
            completionHandler([.badge, .sound, .banner, .list])
        }
    }
    
    // 푸시 클릭: 호두과자 장바구니 담는 화면
    // 유저가 푸시를 클릭했을 때에만 수신 확인 가능
    
    // 특정 푸시를 클릭하면 특정 상세 화면으로 화면 전환 ->
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("사용자가 푸시를 클릭했습니다.")
        
        print(response.notification.request.content.body) // 알림 메시지 출력
        print(response.notification.request.content.userInfo) // 설정해놓은 메시지의 키와 쌍을 출력
        
        let userInfo = response.notification.request.content.userInfo
        
        if userInfo[AnyHashable("sesac")] as? String == "project" {
            // 분기처리하는 부분
            print("SESAC PROJECT")
        }else {
            print("NOTHING")
        }
        
        guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
        
        print(viewController)
        
        // viewController == 최상위뷰를 저장하게 되므로
        // 그에 맞는 분기처리를 할 수 있다.
        if viewController is ViewController {
            viewController.navigationController?.pushViewController(SettingViewController(), animated: true)
        } else if viewController is ProfileViewController {
            viewController.dismiss(animated: true)
        } else if viewController is SettingViewController {
            // settingviewcontroller 라면 pop이 되도록
            viewController.navigationController?.popViewController(animated: true)
        }
        
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
    }

}

