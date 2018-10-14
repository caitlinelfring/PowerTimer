//
//  Settings.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import PTTimer

fileprivate var defaults = UserDefaults.standard

class Settings {
  static let DeviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"

  static var SavedTimerType: PTTimerType {
    set(value) {
      defaults.set(value.rawValue, forKey: "timerType")
    }
    get {
      return PTTimerType(rawValue: defaults.string(forKey: "timerType") ?? PTTimerType.up.rawValue) ?? PTTimerType.up
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
  private static let defaultCountdownMinutes: Int = 15
  static var CountDownTimerMinutes: Int {
    set(value) {
      defaults.set(value, forKey: "CountDownTimerMinutes")
    }
    get {
      return defaults.value(forKey: "CountDownTimerMinutes") as? Int ?? defaultCountdownMinutes
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
      Settings.IntroTips.settings = false
      Settings.IntroTips.stopRestTimer = false
      Settings.IntroTips.startRestTimer = false
      Settings.IntroTips.startTimer = false
    }
  }

  class Sound {
    static var playSoundAlert: Bool {
      set(value) {
        defaults.set(value, forKey: "playSoundAlert")
      }
      get {
        return defaults.bool(forKey: "playSoundAlert")
      }
    }
  }

  static var minScreenDimension: CGFloat {
    let bounds = UIScreen.main.bounds
    return min(bounds.width, bounds.height)
  }

  static var maxScreenDimension: CGFloat {
    let bounds = UIScreen.main.bounds
    return max(bounds.width, bounds.height)
  }

  enum Theme: Int {
    case dark
    case light

    static var available: [Theme] = [.dark, .light]

    var description: String {
      switch self {
      case .dark: return "Dark"
      case .light: return "Light"
      }
    }
  }

  static var currentTheme: Theme {
    set(value) {
      defaults.set(value.rawValue, forKey: "theme")
    }
    get {
      return Theme(rawValue: defaults.integer(forKey: "theme")) ?? Theme.dark
    }
  }

  static var prepareCountdown: Bool {
    set(value) {
      defaults.set(value, forKey: "prepareCountdown")
    }
    get {
      return defaults.bool(forKey: "prepareCountdown")
    }
  }
}

extension UIView {
  func minSafeAreaDimension() -> CGFloat {
    let width = self.frame.width - self.safeAreaInsets.left - self.safeAreaInsets.right
    let height = self.frame.height - self.safeAreaInsets.top - self.safeAreaInsets.bottom
    return min(width, height)
  }
}
