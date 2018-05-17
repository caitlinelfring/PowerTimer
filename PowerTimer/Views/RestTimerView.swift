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

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self

    self.timerLabel.soften(animate: false)
    self.timerLabel.setTime(seconds: 0)
    self.timerLabel.textLabel.text = "Rest Time"
    self.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true


    self.updateStepper()
    self.stepper.addTarget(self, action: #selector(self.stepperValueDidChange), for: .valueChanged)
    self.addSubview(self.stepper)
    self.stepper.translatesAutoresizingMaskIntoConstraints = false
    self.stepper.topAnchor.constraint(equalTo: self.timerLabel.bottomAnchor, constant: 10).isActive = true
    self.stepper.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.stepper.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

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

