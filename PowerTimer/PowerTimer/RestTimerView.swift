//
//  RestTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class RestTimerView: UIView {

  var isEnabled: Bool = false
  let timer = CountUpTimer()
  var tapGestureRecognizer: UITapGestureRecognizer!

  let timerLabel = TimerLabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self

    self.timerLabel.textAlignment = .center
    self.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    self.timerLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    self.isUserInteractionEnabled = true

    self.timerLabel.soften()
    self.timerLabel.setTime(seconds: 0)

    let timerTextLabel = UILabel()
    timerTextLabel.text = "Rest Time"
    timerTextLabel.textColor = .white
    timerTextLabel.textAlignment = .center
    timerTextLabel.font = UIFont.systemFont(ofSize: 16)
    timerTextLabel.adjustsFontSizeToFitWidth = true
    self.addSubview(timerTextLabel)
    timerTextLabel.translatesAutoresizingMaskIntoConstraints = false
    timerTextLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    timerTextLabel.topAnchor.constraint(equalTo: self.timerLabel.bottomAnchor).isActive = true
    timerTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startTap))
    self.addGestureRecognizer(self.tapGestureRecognizer)
  }

  @objc private func startTap(sender: UITapGestureRecognizer) {
    if !self.isEnabled {
      return
    }
    if self.timer.isActive {
      self.timerLabel.soften()
      self.timer.reset()
    } else {
      self.timerLabel.reset()
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
    let totalRestSeconds = Settings.RestTimerMinutes * 60
    self.timerLabel.textColor = seconds > totalRestSeconds ? Colors.red : .white
  }

  func onPaused() {
    print(#function)
  }

  func onStart() {
    print(#function)
  }

  func onReset() {
    print(#function)
    self.timerLabel.setTime(seconds: 0)
  }
}

