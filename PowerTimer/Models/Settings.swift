//
//  Settings.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation

fileprivate var defaults = UserDefaults.standard

class Settings {
  static var SavedTimerType: TimerType {
    set(value) {
      defaults.set(value.rawValue, forKey: "timerType")
    }
    get {
      return TimerType(rawValue: defaults.integer(forKey: "timerType")) ?? TimerType.countUp
    }
  }

  static var RestTimerMinutes: Int {
    set(value) {
      defaults.set(value, forKey: "restTimerMinutes")
    }
    get {
      return defaults.value(forKey: "restTimerMinutes") as? Int ?? 1
    }
  }
  class IntroTips {
    private class func key(_ suffix: String) -> String {
      return "hasSeenIntroTip_\(suffix)"
    }
    static var startTimer: Bool {
      set(value) {
        defaults.set(value, forKey: key("startTimer"))
      }
      get {
        return defaults.bool(forKey: key("startTimer"))
      }
    }
    static var startRestTimer: Bool {
      set(value) {
        defaults.set(value, forKey: key("startRestTimer"))
      }
      get {
        return defaults.bool(forKey: key("startRestTimer"))
      }
    }
    static var stopRestTimer: Bool {
      set(value) {
        defaults.set(value, forKey: key("stopRestTimer"))
      }
      get {
        return defaults.bool(forKey: key("stopRestTimer"))
      }
    }
    static var settings: Bool {
      set(value) {
        defaults.set(value, forKey: key("settings"))
      }
      get {
        return defaults.bool(forKey: key("settings"))
      }
    }

    static func reset() {
      settings = false
      stopRestTimer = false
      startRestTimer = false
      startTimer = false
    }
  }

}
