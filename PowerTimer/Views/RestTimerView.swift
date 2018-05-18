//
//  RestTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import ValueStepper
import SnapKit

class RestTimerView: TimerActions {

  var isEnabled: Bool = false
  let timer = CountUpTimer()
  var tapGestureRecognizer: UITapGestureRecognizer!

  let timerView = TimerView()
  let stepper = RestTimerStepper()
  var onTimerStartAttemptedWhileDisabled: (() -> ())?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self

    self.timerView.soften(animate: false)
    self.timerView.setTime(seconds: 0)
    self.timerView.textLabel.text = "Rest Time"
    self.addSubview(self.timerView)
    self.timerView.snp.makeConstraints { (make) in
      make.top.left.right.equalToSuperview()
    }

    self.updateStepper()
    self.stepper.addTarget(self, action: #selector(self.stepperValueDidChange), for: .valueChanged)
    self.addSubview(self.stepper)
    self.stepper.snp.makeConstraints { (make) in
      make.top.equalTo(self.timerView.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startTap))
    self.tapGestureRecognizer.cancelsTouchesInView = false
    self.addGestureRecognizer(self.tapGestureRecognizer)
  }

  func updateStepper() {
    let current = Double(Settings.RestTimerMinutes)
    if self.stepper.value != current {
      self.stepper.value = current
    }
  }

  @objc private func stepperValueDidChange(sender: ValueStepper) {
    Settings.RestTimerMinutes = Int(sender.value)
  }

  @objc private func startTap(sender: UITapGestureRecognizer) {
    print(#function)
    // Ignore taps on the stepper
    if self.stepper.frame.contains(sender.location(in: self)) {
      print("tapped stepper")
      return
    }

    if !self.isEnabled {
      self.onTimerStartAttemptedWhileDisabled?()
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

  func timerLabelColorChanged(to: UIColor) -> Bool {
    if to == TimerView.Constants.Inactive.textColor {
      return false
    }
    return to != self.timerView.color
  }
}

extension RestTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, String(describing: type(of: self)), seconds)
    self.timerView.setTime(seconds: seconds)
    let restTimerSeconds = Settings.RestTimerMinutes * 60
    var textColor: UIColor = TimerView.Constants.Active.textColor

    // Only use the warning label a minute before the restTimer is over
    // if the restTimeOver is more than a minute
    if restTimerSeconds > 60 && seconds >= restTimerSeconds - 60 {
      textColor = .orange
    }
    if seconds >= restTimerSeconds {
      textColor = .red
    }

    if seconds == 0 {
      textColor = TimerView.Constants.Inactive.textColor
    }
    if self.timerLabelColorChanged(to: textColor) {
      self.timerView.shake()
    }

    self.timerView.color = textColor
  }

  func onPaused() {
    print(#function)
    self.onTimerPaused?()
  }

  func onStart() {
    print(#function)
    self.timerView.enlarge()
    self.stepper.isHidden = true
    self.onTimerStart?()
  }

  func onReset() {
    print(#function)
    self.timerView.soften()
    self.timerView.setTime(seconds: 0)
    self.stepper.isHidden = false
    self.onTimerReset?()
  }
}

