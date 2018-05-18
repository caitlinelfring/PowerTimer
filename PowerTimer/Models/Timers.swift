//
//  Timers.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation

enum TimerType: Int {
  case countUp
  case countDown // TODO: Not implemented

  var description: String {
    switch self {
    case .countUp:
      return "Up"
    case .countDown:
      return "Down"
    }
  }

  static var available: [TimerType] {
    return [.countUp, .countDown]
  }
}

protocol TimerDelegate: class {
  func onTimeChanged(seconds: Int)
  func onPaused()
  func onStart()
  func onReset()
}

class CountTimer {
  fileprivate(set) var currentSeconds: Int = 0 {
    didSet {
      if oldValue != self.currentSeconds {
        self.delegate?.onTimeChanged(seconds: self.currentSeconds)
      }
    }
  }
  fileprivate var timer: Timer?
  var startTime: TimeInterval!
  weak var delegate: TimerDelegate?
  var elapsedTime = TimeInterval()
  var isActive: Bool {
    return self.timer != nil
  }
  var isPaused: Bool {
    return self.currentSeconds > 0 && !self.isActive
  }

  func timerBlock(_ timer: Timer) {
    let currentTime = Date.timeIntervalSinceReferenceDate
    self.elapsedTime = currentTime - self.startTime
  }
  func start() {
    if self.timer != nil {
      return
    }
    self.startTime = Date.timeIntervalSinceReferenceDate - TimeInterval(self.elapsedTime)
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: self.timerBlock)
    self.delegate?.onStart()
  }
  func pause() {
    self.invalidate()
    self.delegate?.onPaused()
  }
  func reset() {
    self.startTime = nil
    self.elapsedTime = 0
    self.invalidate()
    self.delegate?.onReset()
  }
  private func invalidate() {
    self.timer?.invalidate()
    self.timer = nil
  }
}

class CountUpTimer: CountTimer {
  private let maxSecond: Int = 90 * 60 // 90 minutes

  override func timerBlock(_ timer: Timer) {
    super.timerBlock(timer)
    self.currentSeconds = Int(self.elapsedTime)
    if self.currentSeconds > self.maxSecond {
      self.pause()
    }
  }

  override func reset() {
    self.currentSeconds = 0
    super.reset()
  }
}

class CountDownTimer: CountTimer {
  private var startSeconds: Int

  init(seconds: Int) {
    self.startSeconds = seconds
    super.init()
    self.currentSeconds = seconds
  }

  override func timerBlock(_ timer: Timer) {
    super.timerBlock(timer)
    self.currentSeconds =  self.startSeconds - Int(self.elapsedTime)
    if self.currentSeconds == 0 {
      self.pause()
    }
  }
  override func reset() {
    self.currentSeconds = self.startSeconds
    super.reset()
  }
}
