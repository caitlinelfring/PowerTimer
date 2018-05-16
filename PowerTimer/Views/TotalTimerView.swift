//
//  TotalTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class TimerActions: UIView {
  var onTimerStart: (() -> ())?
  var onTimerPaused: (() -> ())?
  var onTimerReset: (() -> ())?
}

class TotalTimerView: TimerActions {
  let timer = CountUpTimer()

  let timerView = TimerView()
  let playButton = PlayButton()
  let pauseButton = PauseButton()
  let refreshButton = RefreshButton()

  var resetTimerRequested: (() -> ())?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self
    self.addSubview(self.timerView)
    self.timerView.translatesAutoresizingMaskIntoConstraints = false
    self.timerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    self.timerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    self.timerView.enlarge()
    self.timerView.setTime(seconds: 0)
    self.timerView.textLabel.text = "Total Time"

    let buttonStack = UIStackView()
    buttonStack.spacing = 10
    self.addSubview(buttonStack)
    buttonStack.translatesAutoresizingMaskIntoConstraints = false
    buttonStack.centerXAnchor.constraint(equalTo: self.timerView.centerXAnchor).isActive = true
    buttonStack.topAnchor.constraint(equalTo: self.timerView.bottomAnchor, constant: 15).isActive = true
    buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
    buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//    buttonStack.widthAnchor.constraint(equalToConstant: 50*2+buttonStack.spacing).isActive = true
    buttonStack.addArrangedSubview(self.playButton)
    buttonStack.addArrangedSubview(self.pauseButton)
    buttonStack.addArrangedSubview(self.refreshButton)

    self.playButton.addTarget(self, action: #selector(self.startTimer), for: .touchUpInside)
    self.pauseButton.addTarget(self, action: #selector(self.pauseTimer), for: .touchUpInside)
    self.refreshButton.addTarget(self, action: #selector(self.resetTimer), for: .touchUpInside)

    self.updateButtonStates()
  }

  @objc private func startTimer(sender: ImageButton) {
    print(#function)
    self.timer.start()
  }

  @objc private func pauseTimer(sender: ImageButton) {
    print(#function)
    self.timer.pause()
  }

  @objc private func resetTimer(sender: ImageButton) {
    print(#function)
    self.resetTimerRequested?()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateButtonStates() {
    self.playButton.isHidden = self.timer.isActive
    self.pauseButton.isHidden = !self.playButton.isHidden
  }
}


extension TotalTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, seconds)
    self.timerView.setTime(seconds: seconds)
  }

  func onPaused() {
    print(#function)
    self.updateButtonStates()
    self.onTimerPaused?()
  }

  func onStart() {
    print(#function)
    self.updateButtonStates()
    self.onTimerStart?()
  }

  func onReset() {
    print(#function)
    self.timerView.color = .white
    self.timerView.setTime(seconds: 0)
    self.timerView.enlarge()
    self.updateButtonStates()
    self.onTimerReset?()
  }
}

