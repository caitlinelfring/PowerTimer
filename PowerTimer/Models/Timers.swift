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

class CountUpTimer {
  private var currentSeconds: Int = 0 {
    didSet {
      self.delegate?.onTimeChanged(seconds: self.currentSeconds)
    }
  }
  private var timer: Timer?
  weak var delegate: TimerDelegate?

  private let maxSecond: Int = 90 * 60

  var isActive: Bool {
    return self.timer != nil
  }

  var isPaused: Bool {
    return self.currentSeconds > 0 && !self.isActive
  }

  func start() {
    if self.timer != nil {
      return
    }
    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
      self.currentSeconds += 1
      if self.currentSeconds > self.maxSecond {
        self.pause()
      }
    })
    self.delegate?.onStart()
  }
  func pause() {
    self.invalidate()
    self.delegate?.onPaused()
  }
  func reset() {
    self.invalidate()
    self.currentSeconds = 0
    self.delegate?.onReset()
  }

  private func invalidate() {
    self.timer?.invalidate()
    self.timer = nil
  }
}

class CountDownTimer {
  private var currentSeconds: Int = 0 {
    didSet {
      self.delegate?.onTimeChanged(seconds: self.currentSeconds)
    }
  }
  private var timer: Timer?
  private var startSeconds: Int

  weak var delegate: TimerDelegate?

  init(seconds: Int) {
    self.startSeconds = seconds
  }
  func start() {
    self.timer = Timer(timeInterval: 1, repeats: true, block: { _ in
      self.currentSeconds -= 1
    })
  }
  func pause() {
    self.timer?.invalidate()
    self.delegate?.onPaused()
  }
  func reset() {
    self.timer?.invalidate()
    self.currentSeconds = self.startSeconds
    self.delegate?.onReset()
  }
}
