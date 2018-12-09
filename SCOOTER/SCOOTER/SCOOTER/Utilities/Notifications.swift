//
//  Notifications.swift
//  SCOOTER
//
//  Created by RoyIM on 11/17/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import Foundation
import UserNotifications

func showEndRidingNotification(cost:String, completion:(() -> Void)? = nil){
    let content = UNMutableNotificationContent()
//    content.title = "title"
    content.body = String(format:"Thanks for your ride, it costs only %@", cost)
    content.sound = UNNotificationSound.default()
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
    
    let request = UNNotificationRequest(identifier: "testIdentifire", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    completion?()
}

func showRequireChargingBalanceNotification(balance:String, completion:((Bool) -> Void)? = nil){
    
    if let balanceFloat = Float(balance) {
        if balanceFloat < 2.0 {
            let content = UNMutableNotificationContent()
            content.body = String(format:"Your balance is $ %@ now. Please charge.", balance)
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: "lowbalance", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            completion?(false)
        }else{
            completion?(true)
        }
        
    }
    
}
