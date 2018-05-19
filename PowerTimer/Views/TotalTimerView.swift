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

class TimerActions: UIView {
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
}

class TotalTimerView: TimerActions {
  var timer: CountTimer!
  let timerView = TimerView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.updateCountTimer()

    self.addSubview(self.timerView)
    self.timerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    self.timerView.enlarge()
    self.timerView.textLabel.text = "Total Time"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func updateCountTimer() {
    if Settings.SavedTimerType == .countDown {
      self.timer = CountDownTimer(seconds: Settings.CountDownTimerMinutes * 60)
    } else {
      self.timer = CountUpTimer()
    }
    self.timer.delegate = self
    self.timerView.setTime(seconds: self.timer.currentSeconds)
  }
}

extension TotalTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, String(describing: type(of: self)), seconds)
    self.timerView.setTime(seconds: seconds)
  }

  func onPaused() {
    print(#function)
    self.timerView.color = .yellow
    self.postToObservers(.timerDidPause)
  }

  func onStart() {
    print(#function)
    self.timerView.color = .white
    self.postToObservers(.timerDidStart)
  }

  func onReset() {
    print(#function)
    self.timerView.color = .white
    self.timerView.setTime(seconds: self.timer.currentSeconds)
    self.timerView.enlarge()
    self.postToObservers(.timerDidReset)
  }
}

