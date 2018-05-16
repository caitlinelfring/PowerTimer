//
//  Timers.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation

protocol TimerDelegate: class {
  func onTimeChanged(seconds: Int)
  func onPaused()
  func onStart()
  func onReset()
}

class CountUpTimer {
  private var currentSeconds: Int = 0
  private var timer: Timer?
  weak var delegate: TimerDelegate?

  var isActive: Bool {
    return self.timer != nil
  }

  func start() {
    if self.timer != nil {
      return
    }
    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
      self.currentSeconds += 1
      self.delegate?.onTimeChanged(seconds: self.currentSeconds)
    })
    self.delegate?.onStart()
  }
  func pause() {
    self.timer?.invalidate()
    self.timer = nil
    self.delegate?.onPaused()
  }
  func reset() {
    self.timer?.invalidate()
    self.timer = nil
    self.currentSeconds = 0
    self.delegate?.onReset()
  }
}

class CountDownTimer {
  private var currentSeconds: Int = 0
  private var timer: Timer?
  private var startSeconds: Int

  weak var delegate: TimerDelegate?

  init(seconds: Int) {
    self.startSeconds = seconds
  }
  func start() {
    self.timer = Timer(timeInterval: 1, repeats: true, block: { _ in
      self.currentSeconds -= 1
      self.delegate?.onTimeChanged(seconds: self.currentSeconds)
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
