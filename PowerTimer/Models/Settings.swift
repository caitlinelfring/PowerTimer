//
//  Settings.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation

class Settings {
  static var SavedTimerType: TimerType {
    set(value) {
      UserDefaults.standard.set(value.rawValue, forKey: "timerType")
    }
    get {
      return TimerType(rawValue: UserDefaults.standard.integer(forKey: "timerType")) ?? TimerType.countUp
    }
  }

  static var RestTimerMinutes: Int {
    set(value) {
      UserDefaults.standard.set(value, forKey: "restTimerMinutes")
    }
    get {
      return UserDefaults.standard.value(forKey: "restTimerMinutes") as? Int ?? 1
    }
  }
}
