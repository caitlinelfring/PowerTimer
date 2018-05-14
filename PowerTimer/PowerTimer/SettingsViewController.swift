//
//  SettingsViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

enum TimerType: Int {
  case countUp
  case countDown

  var description: String {
    switch self {
    case .countUp:
      return "Up"
    case .countDown:
      return "Down"
    }
  }
}
class Settings {
  static var SavedTimerType: TimerType {
    set(value) {
      UserDefaults.standard.set(value.rawValue, forKey: "timerType")
    }
    get {
      return TimerType(rawValue: UserDefaults.standard.integer(forKey: "timerType")) ?? TimerType.countUp
    }
  }

  static var ShowSettingsOnEachLaunch: Bool {
    set(value) {
      UserDefaults.standard.set(value, forKey: "showSettingsOnEachLaunch")
    }
    get {
      return UserDefaults.standard.bool(forKey: "showSettingsOnEachLaunch")
    }
  }

  static var RestTimerMinutes: Int {
    set(value) {
      UserDefaults.standard.set(value, forKey: "restTimerMinutes")
    }
    get {
      return UserDefaults.standard.integer(forKey: "restTimerMinutes")
    }
  }
}

class SettingsViewController: UIViewController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  var pickerSet: [String] = {
    var set = [String]()
    for i in 1...10 {
      set.append(String(i))
    }
    return set
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    let close = UIButton(type: .custom)
    close.setTitle("X", for: .normal)
    close.titleLabel?.textAlignment = .center
    close.setTitleColor(.black, for: .normal)
    close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
    self.view.addSubview(close)
    close.translatesAutoresizingMaskIntoConstraints = false
    close.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
    close.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true

    let stackView = UIStackView()
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.axis = .vertical
    stackView.spacing = 50
    stackView.isUserInteractionEnabled = true

    stackView.addArrangedSubview(self.timerTypeView())
    stackView.addArrangedSubview(self.restMinutesView())
    stackView.addArrangedSubview(self.alwaysShowSettings())

    self.view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
//    stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
  }

  private func restMinutesView() -> UIView {
    let view = UIView()
    let label = UILabel()
    label.text = "Rest Timer"
    label.textAlignment = .center
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

    self.restMinutesLabel.font = self.restMinutesLabel.font.withSize(self.restMinutesLabel.font.pointSize - 2)
    self.restMinutesLabel.textAlignment = .center
    self.restMinutesLabel.text = "\(Settings.RestTimerMinutes) minutes"
    view.addSubview(self.restMinutesLabel)
    self.restMinutesLabel.translatesAutoresizingMaskIntoConstraints = false
    self.restMinutesLabel.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    self.restMinutesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    self.restMinutesLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

    let stepper = UIStepper()
    stepper.minimumValue = 1
    stepper.maximumValue = 20
    stepper.stepValue = 1
    stepper.wraps = false
    stepper.value = Double(Settings.RestTimerMinutes)
    stepper.addTarget(self, action: #selector(self.didChangeRestMinutes), for: .valueChanged)
    view.addSubview(stepper)
    stepper.translatesAutoresizingMaskIntoConstraints = false
    stepper.topAnchor.constraint(equalTo: self.restMinutesLabel.bottomAnchor).isActive = true
    stepper.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    stepper.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    return view
  }

  let restMinutesLabel = UILabel()

  @objc func didChangeRestMinutes(sender: UIStepper) {
    Settings.RestTimerMinutes = Int(sender.value)
    self.restMinutesLabel.text = "\(Settings.RestTimerMinutes) minutes"
  }

  private func alwaysShowSettings() -> UIView {

    let view = UIView()
    let label = UILabel()
    label.text = "Always Show Settings?"
    label.textAlignment = .center
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

    let show = UISwitch()
    show.setOn(Settings.ShowSettingsOnEachLaunch, animated: true)
    show.addTarget(self, action: #selector(self.alwaysShowSettingsChanged), for: .valueChanged)
    view.addSubview(show)
    show.translatesAutoresizingMaskIntoConstraints = false
    show.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    show.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    show.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    return view
  }

  @objc private func alwaysShowSettingsChanged(sender: UISwitch) {
    Settings.ShowSettingsOnEachLaunch = sender.isOn
  }

  private func timerTypeView() -> UIView {
    let view = UIView()
    let label = UILabel()
    label.text = "Timer Type"
    label.textAlignment = .center
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

    let items: [TimerType] = [.countUp, .countDown]
    let segmentControl = UISegmentedControl(items: items.map { $0.description })
    segmentControl.addTarget(self, action: #selector(self.didChangeTimerType), for: .valueChanged)
    segmentControl.selectedSegmentIndex = Settings.SavedTimerType.rawValue
    view.addSubview(segmentControl)
    segmentControl.translatesAutoresizingMaskIntoConstraints = false
    segmentControl.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    segmentControl.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    return view
  }

  @objc private func didChangeTimerType(sender: UISegmentedControl) {
    let selected = TimerType(rawValue: sender.selectedSegmentIndex)!
    print(selected)
    Settings.SavedTimerType = selected
  }

  @objc private func close() {
    self.dismiss(animated: true, completion: nil)
  }
}
