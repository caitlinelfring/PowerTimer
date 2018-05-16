//
//  RestTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class RestTimerView: TimerActions {

  var isEnabled: Bool = false
  let timer = CountUpTimer()
  var tapGestureRecognizer: UITapGestureRecognizer!

  let timerLabel = TimerView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self
    self.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    self.timerLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    self.isUserInteractionEnabled = true

    self.timerLabel.soften()
    self.timerLabel.setTime(seconds: 0)
    self.timerLabel.textLabel.text = "Rest Time"

    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startTap))
    self.addGestureRecognizer(self.tapGestureRecognizer)
  }

  @objc private func startTap(sender: UITapGestureRecognizer) {
    print(#function)
    if !self.isEnabled {
      return
    }
    if self.timer.isActive {
      self.timer.reset()
    } else {
      self.timer.start()
    }
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RestTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, seconds)
    self.timerLabel.setTime(seconds: seconds)
    let restTimerSeconds = Settings.RestTimerMinutes * 60
    var textColor: UIColor = .white

    // Only use the warning label a minute before the restTimer is over
    // if the restTimeOver is more than a minute
    if restTimerSeconds >= 60 && seconds >= restTimerSeconds - 60 {
      textColor = .orange
    }
    if seconds >= restTimerSeconds {
      textColor = .red
    }
    self.timerLabel.color = textColor
  }

  func onPaused() {
    print(#function)
    self.onTimerPaused?()
  }

  func onStart() {
    print(#function)
    self.timerLabel.enlarge()
    self.onTimerStart?()
  }

  func onReset() {
    print(#function)
    self.timerLabel.soften()
    self.timerLabel.setTime(seconds: 0)
    self.onTimerReset?()
  }
}

