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
import PTTimer

class RestTimerView: TimerActions {

  var isEnabled: Bool = false
  let stepper = RestTimerStepper()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer = PTTimer.Up()
    self.timer.delegate = self

    self.timerView.state = .inactive
    self.timerView.setTime(seconds: 0)
    self.timerView.textLabel.text = "Rest".uppercased()
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
  }

  override func updateTimerColor() {
    super.updateTimerColor()
    self.stepper.updateColors()
  }

  func addTapGestureRecognizer(to view: UIView) {
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.singleTap))
    singleTap.delegate = self
    view.addGestureRecognizer(singleTap)
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
    if !self.isEnabled {
      self.postToObservers(.timerDidFailToStart)
      return
    }

    if self.isCurrentlyForceTouch {
      return
    }

    if self.timer.state == .running {
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

  // TODO: This force-touch listener stuff should be the entire topView in TimerViewController
  private var isCurrentlyForceTouch: Bool = false

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print(#function)
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print(#function)
    self.isCurrentlyForceTouch = false
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    print(#function)
    self.isCurrentlyForceTouch = false
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if self.timer.state != .running { return }
    if let touch = touches.first {
      if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
        // 3D Touch capable
        let force = touch.force/touch.maximumPossibleForce
        print("% Touch pressure: \(force)")
        if force == 1.0 && !self.isCurrentlyForceTouch {
          self.isCurrentlyForceTouch = true
          let generator = UISelectionFeedbackGenerator()
          generator.prepare()
          generator.selectionChanged()
          self.timer.reset()
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: self.timer.start)
        }
      }
    }
  }
}

extension RestTimerView: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    print(#function)
    if self.stepper.frame.contains(touch.location(in: self)) {
      print("tapped stepper")
      return false
    }
    return true
  }
}

extension RestTimerView: PTTimerDelegate {
  func timerTimeDidChange(seconds: Int) {
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
      let feedback = UINotificationFeedbackGenerator()
      feedback.prepare()
      feedback.notificationOccurred(.warning)
    }

    self.timerView.color = textColor
  }

  func timerDidPause() {
    print(#function)
    self.postToObservers(.timerDidPause)
  }

  func timerDidStart() {
    print(#function)
    self.timerView.state = .active
    self.stepper.isHidden = true
    self.postToObservers(.timerDidStart)
  }

  func timerDidReset() {
    print(#function)
    self.timerView.state = .inactive
    self.timerView.setTime(seconds: 0)
    self.stepper.isHidden = false
    self.postToObservers(.timerDidReset)
  }
}

