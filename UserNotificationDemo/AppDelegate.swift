//
//  AppDelegate.swift
//  UserNotificationDemo
//
//  Created by llj on 2016/12/12.
//  Copyright © 2016年 lilingjie. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let notificationHandler = NotificationHandler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        authorizePushNotification()
        
        // 注册通知类别
        registerNotificationCategories()

        // 注册远程通知
        UIApplication.shared.registerForRemoteNotifications()
        
        // 发送本地通知
//        sendOneLocalNotification()

        return true
    }
    
    func authorizePushNotification() {
        //
        let center = UNUserNotificationCenter.current()
        
        // 获取当前推送设置
        center.getNotificationSettings() {
            settings in
            /*
             notDetermined  0
             denied         1
             authorized     2
             */
            
            print(settings.alertStyle.rawValue)
            
            switch settings.authorizationStatus {
            case .authorized:  return
               
            case .denied:
                let alert = UIAlertController(title: "Tip", message: "Open push notification permission to get better service", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alert.addAction(cancelAction)
                
                let settingAction = UIAlertAction(title: "Setting", style: .default) {
                    action in
                    // 跳转到设置界面
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    if UIApplication.shared.canOpenURL(url!) {
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                }
                alert.addAction(settingAction)
                
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                
            case .notDetermined:
                center.requestAuthorization(options: [.badge, .sound, .alert]) {
                    (granted, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        // 权限验证
        /*
         -param options : 请求
         -param (Bool, Error?) -> Swift.Void : 请求验证结束闭包
         */
        /*
         // APPIcon角标
         public static var badge: UNAuthorizationOptions { get }
         // 声音
         public static var sound: UNAuthorizationOptions { get }
         // 提示框
         public static var alert: UNAuthorizationOptions { get }
         // 车联网 导航
         public static var carPlay: UNAuthorizationOptions { get }
         */
        
        
        /**
         UNUserNotificationCenterDelegate 用来 响应自定义推送处理事件， 在前台的时候接受通知
         指派delegate时机不得晚于app启动完毕，
         一般在下面两个方法之一中设置
         application(_:willFinishLaunchingWithOptions:)
         application(_:didFinishLaunchingWithOptions:)
         */
        
        center.delegate = notificationHandler
        

    }
    
    func sendOneLocalNotification() {
        // 通知内容
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
        
        // 设置推送消息的分类 -- 点击查看 来显示设置的分类可控按钮
        content.categoryIdentifier = "TIMER_EXPIRED"
        
        
        /**
         自定义通知声
         -param: 音频文件路径
         -note: 必须放在app沙盒内或在~/Library/Sound/文件内包含，如果两者都存在的话， ~/Library/Sound/内的优先执行
         
         public convenience init(named name: String)
         */
        content.sound = UNNotificationSound.default()
        
        /*
        UNCalendarNotificationTrigger : 日期提醒
        UNLocationNotificationTrigger : 区域变化提醒
        */
        
        // 设置触发时间
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 6, repeats: false)
        // 推送请求
        let request = UNNotificationRequest(identifier: "MorningAlarm", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        // 发送推送
        center.add(request) {
            error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("send push notification success")
            }
        }
        
        /**
         取消推送：
         
         本地推送 可以通过 APP端手动调用 removePendingNotificationRequests(withIdentifiers:) 或 removeAllPendingNotificationRequests() 方法在推送触发前取消，
         远程推送 只能在服务器端取消
         */
        
    }
    
    /**
     注册通知分类
     作用 ： 通过给通知添加一些自定义的动作按钮让用户点击，可以快速处理相关的一些任务，任何自定义按钮 一旦被按下都会触发移除推送,
     如果使用可控推送的话，App必须明确添加可控推送的支持，所以在启动的时候，必须注册一个或更多定义了你的APP所发的通知类型的分类，
     每一个分类最多有4个自定义按钮事件。banners 最多只能显示两个
     Actionable Notification 只支持iOS watchOS
     */
    func registerNotificationCategories() {
        
        let center = UNUserNotificationCenter.current()
        
        // 创建自定义事件
        /**
         
        // 执行前需要先解锁
         // Whether this action should require unlocking before being performed.
         public static var authenticationRequired: UNNotificationActionOptions { get }
         
         // 被作为警告提示， 类似于UIAlertAction的删除按钮样式
         // Whether this action should be indicated as destructive.
         public static var destructive: UNNotificationActionOptions { get }
         
         // app在前台启动
         // Whether this action should cause the application to launch in the foreground.
         public static var foreground: UNNotificationActionOptions { get }

         */
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL", actions: [], intentIdentifiers: [], options: .customDismissAction)
        
        // 设置文本输入事件
        let inputAction = UNTextInputNotificationAction(identifier: "TEXT_ACTION",
                                                        title: "Input",
                                                        options: .foreground,
                                                        textInputButtonTitle: "Password",
                                                        textInputPlaceholder: "Please input password")
        
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION",
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        
        let stopAction = UNNotificationAction(identifier: "STOP_ACTION",
                                              title: "Stop",
                                              options: .foreground)
        
        let expiredCategory = UNNotificationCategory(identifier: "TIMER_EXPIRED",
                                                     actions: [inputAction, snoozeAction, stopAction],
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
        
        // 注册分类
        center.setNotificationCategories([generalCategory, expiredCategory])
        
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
        
        print("结束 ----")
    }
    
    // MARK: - 注册
    
    /*
     -note: 如果在运行中 deviceToken发生改变的话，这个方法会被调用
     
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // 拿到token 提交给服务器
        let tokenString = deviceToken.hexString
        print(tokenString)
        // 82f8568ba507436b90324663e6f3a0bb90b3314532b669eb04ba29ec8bc256e4
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 获取token 失败
        print(error.localizedDescription)
    }
    
    
}

extension Data {
    var hexString: String {
        return withUnsafeBytes() { (bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}

