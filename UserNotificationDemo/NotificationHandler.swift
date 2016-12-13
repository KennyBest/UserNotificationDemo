//
//  NotificationHandler.swift
//  UserNotificationDemo
//
//  Created by llj on 2016/12/12.
//  Copyright © 2016年 lilingjie. All rights reserved.
//

import UIKit
import UserNotifications


class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    // app处于前台时是否显示推送通知, app处在前台接受到推送时触发
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print(" receive push notification when APP at foreground")
        let options: UNNotificationPresentationOptions = [.badge, .sound, .alert]
        completionHandler(options)
    }
    
    // 响应自定义动作
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 通过UNNotificationResponse 这个类 可以获取当前推送通知的所有信息
        
        //  响应推送通知自带动作事件 查看 清除
        /**
         UNNotificationDismissActionIdentifier ：通过触发非自定义动作事件从面板中移除推送
         UNNotificationDefaultActionIdentifier : 让你知道用户通过触发非自定义动作事件启动APP
         */
        
        if response.notification.request.content.categoryIdentifier == "TIMER_EXPIRED" {
            
            // 处理文本事件
            if response.actionIdentifier == "TEXT_ACTION" {
               let text =  (response as! UNTextInputNotificationResponse).userText
                print("user input text is \(text)")
            }
            
            if response.actionIdentifier == "SNOOZE_ACTION" {
                print("trigger snnoze action")
            }
            else if response.actionIdentifier == "STOP_ACTION" {
                print("trigger stop action")
            }
        }
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print("点击了清除按钮")
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("点击了查看")
        }
        
        
        completionHandler()
        
    }
}
