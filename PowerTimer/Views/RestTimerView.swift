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

  let timerLabel = TimerView()
  let stepper: ValueStepper = {
    let stepper = ValueStepper()
    stepper.tintColor = .white
    stepper.minimumValue = 1
    stepper.maximumValue = 20
    stepper.stepValue = 1
    stepper.autorepeat = false
    stepper.tintColor = TimerView.Constants.Inactive.textColor
    stepper.labelTextColor = TimerView.Constants.Inactive.textColor
    return stepper
  }()

  var onTimerStartAttemptedWhileDisabled: (() -> ())?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self

    self.timerLabel.soften(animate: false)
    self.timerLabel.setTime(seconds: 0)
    self.timerLabel.textLabel.text = "Rest Time"
    self.addSubview(self.timerLabel)
    self.timerLabel.snp.makeConstraints { (make) in
      make.top.left.right.equalToSuperview()
    }

    self.updateStepper()
    self.stepper.addTarget(self, action: #selector(self.stepperValueDidChange), for: .valueChanged)
    self.addSubview(self.stepper)
    self.stepper.snp.makeConstraints { (make) in
      make.top.equalTo(self.timerLabel.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
    }

    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startTap))
    self.tapGestureRecognizer.cancelsTouchesInView = false
    self.addGestureRecognizer(self.tapGestureRecognizer)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
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
    if !self.isEnabled {
      self.onTimerStartAttemptedWhileDisabled?()
      return
    }
    // Ignore taps on the stepper
    if self.stepper.frame.contains(sender.location(in: self)) {
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
    if to == TimerView.Constants.Active.textColor {
      return false
    }
    return to != self.timerLabel.color
  }
}

extension RestTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, String(describing: type(of: self)), seconds)
    self.timerLabel.setTime(seconds: seconds)
    let restTimerSeconds = Settings.RestTimerMinutes * 60
    var textColor: UIColor = TimerView.Constants.Active.textColor

    // Only use the warning label a minute before the restTimer is over
    // if the restTimeOver is more than a minute
    if restTimerSeconds >=/*remove =*/ 60 && seconds >= restTimerSeconds - 60 {
      textColor = .orange
    }
    if seconds >= restTimerSeconds {
      textColor = .red
    }
    if self.timerLabelColorChanged(to: textColor) {
      self.timerLabel.shake()
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
    self.stepper.isHidden = true
    self.onTimerStart?()
  }

  func onReset() {
    print(#function)
    self.timerLabel.soften()
    self.timerLabel.setTime(seconds: 0)
    self.stepper.isHidden = false
    self.onTimerReset?()
  }
}

