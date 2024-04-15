//
//  ViewController.swift
//  Project21
//
//  Created by Guillermo Suarez on 13/4/24.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
        
    }

    @objc func registerLocal() {
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted {
                
                print("Yay!")
            } else {
                
                print("D'oh!")
            }
        }
    }
    
    @objc func scheduleLocal() {
        
        registerCategories()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        requestNotification(withTrigger: trigger)
    }
    
    func requestNotification(withTrigger trigger: UNNotificationTrigger) {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the sencond mouse gets the cheese"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func registerCategories() {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let remind = UNNotificationAction(identifier: "remind", title: "Remind me later", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            
            print("Custom data received: \(customData)")
            
            let message: String
            
            switch response.actionIdentifier {
                
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                message = "Defaul action"
            case "show":
                print("Show more information.")
                message = "Show more action"
                
            case "remind":
                print("Remind me later.")
                message = "Remind me later action"
                
                let today = Date()
                let calendar = Calendar.current
                let dateComponents = DateComponents(day: 1)
                
                if let tomorrow = calendar.date(byAdding: dateComponents, to: today, wrappingComponents: false) {
                    
                    let tomorrowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: tomorrow)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrowComponents, repeats: false)
                    
//                    print("date remind: \(trigger.nextTriggerDate())")
//                    print("today date: \(Date())")
//                    print("tomorrow date: \(tomorrow)")
                    requestNotification(withTrigger: trigger)
                }
                
            default:
                message = "Another action"
                break
            }
            
            let ac = UIAlertController(title: "Notification Action", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(ac, animated: true)
        }
        
        completionHandler()
    }
}

