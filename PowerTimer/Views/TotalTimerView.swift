//
//  TotalTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import PTTimer

class TimerActions: UIView {

  var timer: PTTimer!
  let timerView = TimerView()

  enum Event: String {
    case timerDidStart
    case timerDidPause
    case timerDidReset
    case timerDidFailToStart

    func name() -> Notification.Name {
      return Notification.Name(self.rawValue)
    }
  }

  // The purpose of IAPManager and these observers is to contain all StoreKit logic here and
  // let the observers listen to events and update their UIs accordingly
  func addObserver(_ callback: @escaping ((Event, [AnyHashable: Any]?) -> Void)) -> NSObjectProtocol {
    return NotificationCenter.default.addObserver(forName: nil, object: self, queue: OperationQueue.current, using: { notification in
      let event = Event(rawValue: notification.name.rawValue)!
      callback(event, notification.userInfo)
    })
  }

  func removeObserver(_ observer: NSObjectProtocol) {
    NotificationCenter.default.removeObserver(observer)
  }

  func postToObservers(_ event: Event) {
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: event.name(), object: self, userInfo: nil)
    }
  }

  func updateTimerColor() {
    self.timerView.color = self.timerView.state.color()
  }
}

class TotalTimerView: TimerActions {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.updateTimerColor()
    self.timerView.state = .active
    self.timerView.textLabel.text = "Total".uppercased()

    self.addSubview(self.timerView)
    self.timerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    self.updateCountTimer()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func updateCountTimer() {
    if self.timer != nil {
      self.timer.delegate = nil
      self.timer = nil
    }

    if Settings.SavedTimerType == .down {
      self.timer = PTTimer.Down(startSeconds: Settings.CountDownTimerMinutes * 60)
    } else {
      self.timer = PTTimer.Up()
    }
    self.timer.delegate = self
    self.timer.reset()
  }
}

extension TotalTimerView: PTTimerDelegate {
  func timerTimeDidChange(seconds: Int) {
    self.timerView.setTime(seconds: seconds)
  }

  func timerDidPause() {
    self.timerView.state = .paused
    self.postToObservers(.timerDidPause)
  }

  func timerDidStart() {
    self.timerView.state = .active
    self.postToObservers(.timerDidStart)
  }

  func timerDidReset() {
    self.timerView.state = .active
    self.timerView.setTime(seconds: self.timer.seconds())
    self.postToObservers(.timerDidReset)
  }
}

