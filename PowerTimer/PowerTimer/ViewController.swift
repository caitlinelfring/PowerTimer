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
  let startStopBtn = Button(color: Colors.green)

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)

    self.view.backgroundColor = .black
    self.timer.delegate = self

    self.startStopBtn.label.text = "Start"
    self.view.addSubview(self.startStopBtn)
    self.startStopBtn.translatesAutoresizingMaskIntoConstraints = false
    self.startStopBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
    self.startStopBtn.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
    self.startStopBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.startStopBtn.addTarget(self, action: #selector(self.startStopBtnTapped), for: .touchUpInside)

    self.timerLabel.textAlignment = .center
    self.view.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.timerLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

    let timerTextLabel = UILabel()
    timerTextLabel.text = "Total Time"
    timerTextLabel.textColor = .white
    timerTextLabel.textAlignment = .center
    timerTextLabel.font = UIFont.systemFont(ofSize: 20)
    timerTextLabel.adjustsFontSizeToFitWidth = true
    self.view.addSubview(timerTextLabel)
    timerTextLabel.translatesAutoresizingMaskIntoConstraints = false
    timerTextLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    timerTextLabel.topAnchor.constraint(equalTo: self.timerLabel.bottomAnchor).isActive = true
    timerTextLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

    let reset = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.resetBtnTapped))
    self.navigationItem.rightBarButtonItem = reset
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }

  @objc private func resetBtnTapped(sender: Button) {
    print(#function)
    self.timer.reset()
    self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    self.startStopBtn.set(color: Colors.green)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }

  func onStart() {
    print(#function)
    self.timerLabel.textColor = .green
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    self.startStopBtn.label.text = "Pause"
    self.startStopBtn.set(color: Colors.orange)
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
    self.adjustsFontSizeToFitWidth = true
    self.setTime(seconds: 0)
  }

  func setTime(seconds: Int) {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    let time = String(format: "%02d:%02d", minutesValue, secondsValue)
    let attributes: [NSAttributedStringKey: Any] = [
      NSAttributedStringKey.kern: 5,
      NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: UIScreen.main.bounds.width * 0.2)!,
      NSAttributedStringKey.foregroundColor: UIColor.white,
    ]
    let attributedText = NSAttributedString(string: time, attributes: attributes)
    self.attributedText = attributedText
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
