//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TimerDelegate {
  let timerLabel = TimerLabel()
  let timer = CountUpTimer()
  let startStopBtn = Button(color: .green)
  let resetBtn = Button(color: .red)


  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .black
    self.timer.delegate = self

    self.startStopBtn.label.text = "Start"
    self.view.addSubview(self.startStopBtn)
    self.startStopBtn.translatesAutoresizingMaskIntoConstraints = false
    self.startStopBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
    self.startStopBtn.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
    self.startStopBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.startStopBtn.addTarget(self, action: #selector(self.startStopBtnTapped), for: .touchUpInside)

    self.resetBtn.isHidden = true
    self.resetBtn.label.text = "Reset"
    self.view.addSubview(self.resetBtn)
    self.resetBtn.translatesAutoresizingMaskIntoConstraints = false
    self.resetBtn.bottomAnchor.constraint(equalTo: self.startStopBtn.topAnchor, constant: -10).isActive = true
    self.resetBtn.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
    self.resetBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.resetBtn.addTarget(self, action: #selector(self.resetBtnTapped), for: .touchUpInside)

    self.timerLabel.textAlignment = .center
    self.view.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.timerLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
  }

  @objc private func resetBtnTapped(sender: Button) {
    print(#function)
    self.timer.reset()
    self.resetBtn.isHidden = true
  }
  @objc private func startStopBtnTapped(sender: Button) {
    print(#function)
    if self.startStopBtn.label.text == "Start" {
      self.timer.start()
    } else {
      self.timer.pause()
    }
  }

  func onTimeChanged(seconds: Int) {
    print(#function, seconds)
    self.timerLabel.setTime(seconds: seconds)
  }

  func onPaused() {
    print(#function)
    self.timerLabel.textColor = .orange
    self.startStopBtn.label.text = "Start"
    self.startStopBtn.set(color: .green)
    self.resetBtn.isHidden = false
  }

  func onStart() {
    print(#function)
    self.timerLabel.textColor = .green
    self.resetBtn.isHidden = true
    self.startStopBtn.label.text = "Pause"
    self.startStopBtn.set(color: .yellow)
  }

  func onReset() {
    print(#function)
    self.timerLabel.textColor = .white
    self.timerLabel.setTime(seconds: 0)
  }
}


class TimerLabel: UILabel {

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.textColor = .white
    self.font = UIFont.boldSystemFont(ofSize: UIScreen.main.bounds.width * 0.2)
    self.adjustsFontSizeToFitWidth = true
    self.setTime(seconds: 0)
  }

  func setTime(seconds: Int) {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    self.text = String(format: "%02d:%02d", minutesValue, secondsValue)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class Button: UIButton {
  static var height: CGFloat {
    return min(55, UIScreen.main.bounds.height * 0.075)
  }

  fileprivate var label = UILabel()
  fileprivate var heightConstraint: NSLayoutConstraint!

  convenience init(color: UIColor) {
    self.init(frame: .zero)
    self.set(color: color)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.set(color: .gray)

    self.translatesAutoresizingMaskIntoConstraints = false
    self.heightConstraint = self.heightAnchor.constraint(equalToConstant: Button.height)
    self.heightConstraint.isActive = true

    self.isUserInteractionEnabled = true

    self.layer.cornerRadius = 2.0
    self.layer.masksToBounds = true
    self.label.numberOfLines = 0
    self.label.adjustsFontSizeToFitWidth = true
    self.label.textColor = UIColor.white
    self.label.backgroundColor = .clear
    self.label.textAlignment = .center
    self.addSubview(self.label)
    self.label.translatesAutoresizingMaskIntoConstraints = false
    self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    self.label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
    self.label.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func deactivateHeightConstraint() {
    self.heightConstraint.isActive = false
  }

  func set(color: UIColor) {
    self.layer.backgroundColor = color.cgColor
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let bounds = self.bounds
    self.layer.cornerRadius = bounds.height / 2
  }
}
