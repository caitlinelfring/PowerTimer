//
//  Notifications.swift
//  PowerTimer
//
//  Created by Caitlin on 11/17/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications {

  static var granted: Bool = false

  class func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, err) in
      if let err = err {
        print("Error requesting push notification: \(err)")
      }
      granted = success
    }
  }

  class func clearPending() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }

  class func notifyRest(seconds: Int) {
    guard granted else { return }
    let restTimerSeconds = Settings.RestTimerMinutes * 60
    let notifySeconds = restTimerSeconds - seconds
    guard notifySeconds > 0 else { return }
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notifySeconds), repeats: false)
    let content = UNMutableNotificationContent()
    content.title = "REST OVER!"
    content.body = "You've been resting for \(Settings.RestTimerMinutes) minute\(Settings.RestTimerMinutes > 1 ? "s" : "")."
    content.categoryIdentifier = "alarm"
    content.sound = UNNotificationSound.default

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (err) in
      if let err = err {
        print("Error adding local notification: \(err)")
      }
    }
  }
}
