//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

// TODO
// Light/dark theme
// rest timer

import UIKit

// Since I'm not subclassing UINavigationController, this is the simplist way
// to get the status bar styles working correctly in a navigation stack
// https://stackoverflow.com/questions/19108513/uistatusbarstyle-preferredstatusbarstyle-does-not-work-on-ios-7
extension UINavigationController {
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    if let first = self.viewControllers.first {
      return first.preferredStatusBarStyle
    }
    return super.preferredStatusBarStyle
  }
}

class ViewController: UIViewController {
  let timerLabel = TimerLabel()
  let timer = CountUpTimer()
  let startStopBtn = Button(color: Colors.green)
  let restTimerView = RestTimerView()
  private var restTimerViewTopConstraint: NSLayoutConstraint!

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
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

    self.view.addSubview(self.restTimerView)
    self.restTimerView.translatesAutoresizingMaskIntoConstraints = false
    self.restTimerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.restTimerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    var navHeight = self.navigationController?.navigationBar.bounds.height ?? 0
    navHeight += UIApplication.shared.statusBarFrame.height
    self.restTimerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: navHeight).isActive = true

    let reset = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.resetBtnTapped))
    self.navigationItem.rightBarButtonItem = reset

    let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.presentSettings))
    self.navigationItem.leftBarButtonItem = settings

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    self.navigationController?.navigationBar.tintColor = .white
    if Settings.ShowSettingsOnEachLaunch {
      self.presentSettings()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  @objc private func presentSettings() {
    UIApplication.shared.keyWindow?.rootViewController?.present(SettingsViewController(), animated: true, completion: nil)
  }

  func setIdleTimer(enabled: Bool) {
    UIApplication.shared.isIdleTimerDisabled = !enabled
  }

  @objc private func resetBtnTapped(sender: Button) {
    print(#function)
    let alert = UIAlertController(title: "Are you sure you want to reset the timer?", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
      self.timer.reset()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  @objc private func startStopBtnTapped(sender: Button) {
    print(#function)
    if self.startStopBtn.label.text == "Start" {
      self.timer.start()
    } else {
      self.timer.pause()
    }
  }
}

extension ViewController: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, seconds)
    if self.restTimerView.timer.isActive {
      self.timerLabel.soften()
    } else {
      self.timerLabel.reset()
    }
    self.timerLabel.setTime(seconds: seconds)
  }

  func onPaused() {
    print(#function)
    self.timerLabel.textColor = .orange
    self.startStopBtn.label.text = "Start"
    self.startStopBtn.set(color: Colors.green)
    self.setIdleTimer(enabled: true)
    self.timerLabel.reset()
    self.restTimerView.timerLabel.soften()
    self.restTimerView.timer.reset()
    self.restTimerView.isEnabled = false
  }

  func onStart() {
    print(#function)
    self.timerLabel.textColor = .white
    self.startStopBtn.label.text = "Pause"
    self.startStopBtn.set(color: Colors.orange)
    self.setIdleTimer(enabled: false)
    self.restTimerView.isEnabled = true
  }

  func onReset() {
    print(#function)
    self.timerLabel.textColor = .white
    self.timerLabel.setTime(seconds: 0)
    self.setIdleTimer(enabled: true)
    self.restTimerView.timerLabel.soften()
    self.restTimerView.timer.reset()
    self.restTimerView.isEnabled = false
    self.timerLabel.reset()
  }
}

class TimerLabel: UILabel {

  class Constants {
    static let font = UIFont(name: "HelveticaNeue-Medium", size: UIScreen.main.bounds.width * 0.2)!
    static let textColor: UIColor = .white
  }
  var labelFont: UIFont! = Constants.font
  var labelTextColor: UIColor = Constants.textColor

  private var currentText = "00:00" {
    didSet {
      let attributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.kern: 5,
        NSAttributedStringKey.font: self.labelFont,
        NSAttributedStringKey.foregroundColor: self.labelTextColor,
      ]
      let attributedText = NSAttributedString(string: self.currentText, attributes: attributes)
      self.attributedText = attributedText
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.adjustsFontSizeToFitWidth = true
    self.setTime(seconds: 0)
  }

  func setTime(seconds: Int) {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    self.currentText = String(format: "%02d:%02d", minutesValue, secondsValue)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func soften() {
    UIView.animate(withDuration: 1) {
      self.labelFont = Constants.font.withSize(Constants.font.pointSize - 6)
      self.labelTextColor = .gray
      let text = self.currentText
      self.currentText = text
    }
  }

  func reset() {
    UIView.animate(withDuration: 1) {
      self.labelFont = Constants.font
      self.labelTextColor = Constants.textColor
      let text = self.currentText
      self.currentText = text
    }
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
