//
//  Tips.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import EasyTipView

class TipManager {

  // this is used so the delegate can automatically call the next tip after the previous one dismisses
  var onNextTip: (() -> ())?

  enum TipType {
    case startTimer
    case startRestTimer
    case stopRestTimer
    case settings

    func tipDescription() -> String {
      switch self {
      case .startTimer:
        return "Tap here to start the overall timer"
      case .startRestTimer:
        return "Now that you've started the overall timer, TAP HERE to start your REST timer"
      case .stopRestTimer:
        return "Great! Now you can tap the REST timer again to clear it. Tap again to restart!"
      case .settings:
        return "Head into settings for more info!"
      }
    }

    func set(shown: Bool) {
      switch self {
      case .startTimer:
        Settings.IntroTips.startTimer = shown
      case .startRestTimer:
        Settings.IntroTips.startRestTimer = shown
      case .stopRestTimer:
        Settings.IntroTips.stopRestTimer = shown
      case .settings:
        Settings.IntroTips.settings = shown
      }
    }
  }

  class func setup() {
    EasyTipView.globalPreferences = TipManager.preferences
  }

  class func next() -> TipType? {
    if !Settings.IntroTips.startTimer {
      return .startTimer
    } else if !Settings.IntroTips.startRestTimer {
      return .startRestTimer
    } else if !Settings.IntroTips.stopRestTimer {
      return .stopRestTimer
    } else if !Settings.IntroTips.settings {
      return .settings
    } else {
      return nil
    }
  }

  private var currentTipView: EasyTipView?
  private var currentTipType: TipType?

  func show(inView view: UIView, forType type: TipType, withinSuperView superview: UIView? = nil) {
    self.currentTipView = EasyTipView(text: type.tipDescription(), preferences: TipManager.preferences, delegate: self)
    self.currentTipType = type
    self.currentTipView!.show(animated: true, forView: view, withinSuperview: superview)
    type.set(shown: true)
  }

  func show(forItem item: UIBarItem, forType type: TipType, withinSuperView superview: UIView? = nil) {
    self.currentTipView = EasyTipView(text: type.tipDescription(), preferences: TipManager.preferences, delegate: self)
    self.currentTipType = type
    self.currentTipView!.show(animated: true, forItem: item, withinSuperView: superview)
    type.set(shown: true)
  }

  func dismiss(forType type: TipType, completion: ((Bool) -> ())? = nil) {
    // Only dismiss the current tip if the current type matches what's being requested
    // because we don't want the settings tip to get dismissed if the start button was pressed
    guard type == self.currentTipType else {
      completion?(false)
      return
    }
    self.currentTipView?.dismiss(withCompletion: {
      self.currentTipType = nil
      self.currentTipView = nil
      completion?(true)
    })
  }

  private static var preferences: EasyTipView.Preferences = {
    var preferences = EasyTipView.Preferences()
    preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
    preferences.drawing.foregroundColor = .white
    preferences.drawing.backgroundColor = UIColor(hue: 0.46, saturation: 0.99, brightness: 0.6, alpha: 1)
    preferences.animating.dismissOnTap = false // This is disabled because there are actions in the view controller that manually dismiss the tip
    return preferences
  }()
}

extension TipManager: EasyTipViewDelegate {
  func easyTipViewDidDismiss(_ tipView: EasyTipView) {
    self.onNextTip?()
  }
}
