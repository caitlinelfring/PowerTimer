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
  let stepper = RestTimerStepper()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer = CountUpTimer()
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
      if UIDevice.current.userInterfaceIdiom == .pad {
        make.height.equalTo(35)
      }
      make.bottom.equalToSuperview()
    }

    self.addTapGestureRecognizer(to: self)
  }

  override func updateTimerColor() {
    self.timerView.color = TimerView.Constants.Inactive.textColor
    self.stepper.updateColors()
  }

  func addTapGestureRecognizer(to view: UIView) {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startTap))
    tapGestureRecognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGestureRecognizer)
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
      self.postToObservers(.timerDidFailToStart)
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
      Sounds.playIfConfigured()
    }

    self.timerView.color = textColor
  }

  func onPaused() {
    print(#function)
    self.postToObservers(.timerDidPause)
  }

  func onStart() {
    print(#function)
    self.timerView.enlarge()
    self.stepper.isHidden = true
    self.postToObservers(.timerDidStart)
  }

  func onReset() {
    print(#function)
    self.timerView.soften()
    self.timerView.setTime(seconds: 0)
    self.stepper.isHidden = false
    self.postToObservers(.timerDidReset)
  }
}

