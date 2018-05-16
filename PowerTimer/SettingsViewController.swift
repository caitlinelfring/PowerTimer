//
//  SettingsViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white

    if self.navigationController == nil {
      let close = UIButton(type: .custom)
      close.setTitle("x", for: .normal) // TODO: Better close button
      close.titleLabel?.textAlignment = .center
      close.setTitleColor(.black, for: .normal)
      close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
      self.view.addSubview(close)
      close.translatesAutoresizingMaskIntoConstraints = false
      close.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
      close.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
    }

    let stackView = UIStackView()
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.axis = .vertical
    stackView.spacing = 50
    stackView.isUserInteractionEnabled = true

    stackView.addArrangedSubview(self.timerTypeView())
    stackView.addArrangedSubview(self.restMinutesView())

    self.view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.tintColor = .black
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

    let segmentControl = UISegmentedControl(items: TimerType.available.map { $0.description })
    segmentControl.addTarget(self, action: #selector(self.didChangeTimerType), for: .valueChanged)
    segmentControl.selectedSegmentIndex = Settings.SavedTimerType.rawValue
    view.addSubview(segmentControl)
    segmentControl.translatesAutoresizingMaskIntoConstraints = false
    segmentControl.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    segmentControl.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    // countDown not available yet
    segmentControl.setEnabled(false, forSegmentAt: TimerType.available.index(where: { $0 == TimerType.countDown })!)

    return view
  }

  @objc private func didChangeTimerType(sender: UISegmentedControl) {
    Settings.SavedTimerType = TimerType(rawValue: sender.selectedSegmentIndex)!
  }

  @objc private func close() {
    if let nav = self.navigationController {
      nav.popViewController(animated: true)
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
}
