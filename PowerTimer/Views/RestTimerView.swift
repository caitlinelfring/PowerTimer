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

    self.timerView.state = .inactive
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
    super.updateTimerColor()
    self.stepper.updateColors()
  }

  func addTapGestureRecognizer(to view: UIView) {
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.singleTap))
    singleTap.numberOfTapsRequired = 1
    singleTap.cancelsTouchesInView = false
    view.addGestureRecognizer(singleTap)

    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap))
    doubleTap.numberOfTapsRequired = 2
    doubleTap.cancelsTouchesInView = false
    view.addGestureRecognizer(doubleTap)

    singleTap.require(toFail: doubleTap)
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

  @objc private func singleTap(sender: UITapGestureRecognizer) {
    print(#function)
    self.tap(sender, withTaps: 1)
  }

  @objc private func doubleTap(sender: UITapGestureRecognizer) {
    print(#function)
    self.tap(sender, withTaps: 2)
  }

  private func tap(_ sender: UITapGestureRecognizer, withTaps taps: Int) {
    if self.stepper.frame.contains(sender.location(in: self)) {
      print("tapped stepper")
      return
    }

    if !self.isEnabled {
      self.postToObservers(.timerDidFailToStart)
      return
    }

    if self.timer.state == .running {
      self.timer.reset()
      if taps > 1 {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: self.timer.start)
      }
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
    self.timerView.state = .active
    self.stepper.isHidden = true
    self.postToObservers(.timerDidStart)
  }

  func onReset() {
    print(#function)
    self.timerView.state = .inactive
    self.timerView.setTime(seconds: 0)
    self.stepper.isHidden = false
    self.postToObservers(.timerDidReset)
  }
}
