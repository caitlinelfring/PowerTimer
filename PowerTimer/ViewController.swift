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

    self.timerLabel.timerTextLabel.text = "Total Time"
    self.view.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.timerLabel.topAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

    self.view.addSubview(self.restTimerView)
    self.restTimerView.translatesAutoresizingMaskIntoConstraints = false
    self.restTimerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.restTimerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.restTimerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true

    let reset = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.resetBtnTapped))
    self.navigationItem.leftBarButtonItem = reset

    let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.presentSettings))
    self.navigationItem.rightBarButtonItem = settings

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    self.navigationController?.navigationBar.tintColor = .white
  }

  @objc private func presentSettings() {
    let settingsVC = SettingsViewController()
    if let nav = self.navigationController {
      nav.pushViewController(settingsVC, animated: true)
    } else {
      self.present(settingsVC, animated: true, completion: nil)
    }
  }

  func setIdleTimer(enabled: Bool) {
    UIApplication.shared.isIdleTimerDisabled = !enabled
  }

  @objc private func resetBtnTapped(sender: Button) {
    print(#function)
    if !self.timer.isActive {
      self.timer.reset()
      return
    }
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
    self.timerLabel.labelTextColor = .orange
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
    self.timerLabel.labelTextColor = .white
    self.startStopBtn.label.text = "Pause"
    self.startStopBtn.set(color: Colors.orange)
    self.setIdleTimer(enabled: false)
    self.restTimerView.isEnabled = true
  }

  func onReset() {
    print(#function)
    self.timerLabel.labelTextColor = .white
    self.timerLabel.setTime(seconds: 0)
    self.setIdleTimer(enabled: true)
    self.restTimerView.timerLabel.soften()
    self.restTimerView.timer.reset()
    self.restTimerView.isEnabled = false
    self.timerLabel.reset()
  }
}

class TimerLabel: UIView {

  class Constants {
    static var font: UIFont {
      let bounds = UIScreen.main.bounds
      var fontSize = bounds.width * 0.2
      if bounds.width > bounds.height {
        fontSize = bounds.height * 0.2
      }
      return  UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
    }
    static let textColor: UIColor = .white
  }
  var labelFont: UIFont! = Constants.font
  var labelTextColor: UIColor = Constants.textColor

  let timerLabel = UILabel()
  let timerTextLabel = UILabel()

  private var currentText = "00:00" {
    didSet {
      let attributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.kern: 5,
        NSAttributedStringKey.font: self.labelFont,
        NSAttributedStringKey.foregroundColor: self.labelTextColor,
      ]
      let attributedText = NSAttributedString(string: self.currentText, attributes: attributes)
      self.timerLabel.attributedText = attributedText
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timerLabel.adjustsFontSizeToFitWidth = true
    self.timerLabel.textAlignment = .center
    self.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.setTime(seconds: 0)

    self.timerTextLabel.textColor = .white
    self.timerTextLabel.textAlignment = .center
    self.timerTextLabel.font = UIFont.systemFont(ofSize: 20)
    self.timerTextLabel.adjustsFontSizeToFitWidth = true
    self.addSubview(self.timerTextLabel)
    self.timerTextLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerTextLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerTextLabel.topAnchor.constraint(equalTo: self.timerLabel.bottomAnchor).isActive = true
    self.timerTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.timerTextLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
  }

  func setTime(seconds: Int) {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    self.currentText = String(format: "%02d:%02d", minutesValue, secondsValue)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reset() {
    self.animate(Constants.font, color: Constants.textColor)
  }
  func soften() {
    self.animate(Constants.font.withSize(Constants.font.pointSize - 6), color: .gray)
  }

  func animate(_ font: UIFont, color: UIColor) {
    let duration: TimeInterval = 0.25
    let oldFont = self.timerLabel.font
    self.timerLabel.font = font
    let labelScale = oldFont!.pointSize / font.pointSize
    let oldTransform = self.timerLabel.transform
    self.timerLabel.transform = self.timerLabel.transform.scaledBy(x: labelScale, y: labelScale)
    self.timerLabel.setNeedsUpdateConstraints()

    UIView.animate(withDuration: duration) {
      self.timerLabel.transform = oldTransform
      self.timerLabel.layoutIfNeeded()
    }

    UIView.transition(with: self, duration: 0.25,
                      options: .transitionCrossDissolve,
                      animations: {
                        self.labelTextColor = color
                        self.labelFont = font
                        let attributes: [NSAttributedStringKey: Any] = [
                          NSAttributedStringKey.kern: 5,
                          NSAttributedStringKey.foregroundColor: self.labelTextColor,
                        ]
                        let attributedText = NSAttributedString(string: self.currentText, attributes: attributes)
                        self.timerLabel.attributedText = attributedText
                        self.timerTextLabel.textColor = self.labelTextColor

    })
  }
}

class Button: UIButton {
  static var height: CGFloat {
    let bounds = UIScreen.main.bounds
    var base = bounds.height
    if bounds.width > bounds.height {
      base = bounds.width
    }
    return min(55, base * 0.075)
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
