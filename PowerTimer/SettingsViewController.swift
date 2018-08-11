//
//  SettingsViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import ValueStepper
import SnapKit
import EasyTipView

class SettingTableViewController: UITableViewController {
  struct Item {
    var title: String
    var cell: UITableViewCell
    var didPress: (() -> ())?
    var height: CGFloat
    var shouldEnable: (() -> Bool)

    init(title: String, height: CGFloat = 44, cell: UITableViewCell = UITableViewCell(), didPress: (() -> ())? = nil) {
      self.title = title
      self.height = height
      self.cell = cell
      self.didPress = didPress
      self.shouldEnable = { return true }
    }
  }

  convenience init() {
    self.init(style: .plain)
  }

  private var canChangeTimerType: Bool = true

  private var items = [Item]()
  private var currentTip: EasyTipView?

  override init(style: UITableViewStyle) {
    super.init(style: style)

    let restCell = SettingsCell(accessory: restStepper())
    self.items.append(Item(title: "Rest Time", height: 80, cell: restCell))

    let timerTypeCell = SettingsCell(accessory: timerTypeControl())
    var ttcItem = Item(title: "Timer Type", height: 80, cell: timerTypeCell)
    ttcItem.shouldEnable = { return self.canChangeTimerType }
    ttcItem.didPress = {
      if !self.canChangeTimerType {
        var prefs = EasyTipView.Preferences()
        prefs.animating.dismissOnTap = true
        self.currentTip?.dismiss()
        self.currentTip = EasyTipView(text: "Pause the current timer before changing the timer type.", preferences: prefs, delegate: nil)
        self.currentTip!.show(animated: true, forView: timerTypeCell.accessory, withinSuperview: self.view)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
          self.currentTip?.dismiss()
        })
      }
    }
    self.items.append(ttcItem)

    let countDownTimerMinutesCell = SettingsCell(accessory: countDownTimerStepper())
    var cdt = Item(title: "CountDown Minutes", height: 80, cell: countDownTimerMinutesCell)
    cdt.shouldEnable = { return Settings.SavedTimerType == .countDown && self.canChangeTimerType }
    self.items.append(cdt)

    self.items.append(Item(title: "Reset Intro Tips", didPress: {
      Settings.IntroTips.reset()
      self.dismiss(animated: true, completion: nil)
    }))

    let soundCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    soundCell.accessoryView = soundOnOffSwitch()
    self.items.append(Item(title: "Alerts", cell: soundCell))

    let themeCell = SettingsCell(accessory: themeControl())
    self.items.append(Item(title: "Theme", height: 80, cell: themeCell))

    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.tableHeaderView = UIView()
    self.tableView.tableFooterView = UIView()
    self.tableView.estimatedRowHeight = 44
    self.tableView.rowHeight = 44

    self.navigationItem.title = "SETTINGS"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.currentTip?.dismiss()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let vc = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.childViewControllers.first as? TimerViewController {
      self.canChangeTimerType = !vc.totalTimerView.timer.isActive && !vc.totalTimerView.timer.isPaused
    }
  }

  func restStepper() -> ValueStepper {
    let stepper = RestTimerStepper()
    stepper.labelTextColor = self.view.tintColor
    stepper.value = Double(Settings.RestTimerMinutes)
    stepper.addTarget(self, action: #selector(self.didChangeRestMinutes), for: .valueChanged)
    return stepper
  }

  func countDownTimerStepper() -> ValueStepper {
    let stepper = SettingsCountDownTimerStepper()
    stepper.labelTextColor = self.view.tintColor
    stepper.value = Double(Settings.CountDownTimerMinutes)
    stepper.addTarget(self, action: #selector(self.didChangeCountDownTimerMinutes), for: .valueChanged)
    return stepper
  }

  private func timerTypeControl() -> UISegmentedControl {
    let segmentControl = UISegmentedControl(items: TimerType.available.map { $0.description })
    segmentControl.addTarget(self, action: #selector(self.didChangeTimerType), for: .valueChanged)
    segmentControl.selectedSegmentIndex = Settings.SavedTimerType.rawValue
    return segmentControl
  }

  private func themeControl() -> UISegmentedControl {
    let segmentControl = UISegmentedControl(items: Settings.Theme.available.map { $0.description })
    segmentControl.addTarget(self, action: #selector(self.didChangeTheme), for: .valueChanged)
    segmentControl.selectedSegmentIndex = Settings.currentTheme.rawValue
    return segmentControl
  }

  @objc private func didChangeTheme(sender: UISegmentedControl) {
    Settings.currentTheme = Settings.Theme(rawValue: sender.selectedSegmentIndex)!

    let nav = self.presentingViewController as! UINavigationController
    let parent = nav.childViewControllers.first! as! TimerViewController
    parent.setColors()
    parent.overrideStatusBar = Settings.currentTheme == .light ? .lightContent : nil
    parent.setNeedsStatusBarAppearanceUpdate()
    parent.view.layoutSubviews()
  }

  private func soundOnOffSwitch() -> UISwitch {
    let soundSwitch = UISwitch()
    soundSwitch.setOn(Settings.Sound.playSoundAlert, animated: false)
    soundSwitch.addTarget(self, action: #selector(self.soundSwitchDidChange), for: .valueChanged)
    return soundSwitch
  }

  @objc func soundSwitchDidChange(sender: UISwitch) {
    Settings.Sound.playSoundAlert = sender.isOn
  }

  @objc func didChangeRestMinutes(sender: UIStepper) {
    Settings.RestTimerMinutes = Int(sender.value)
  }

  @objc func didChangeCountDownTimerMinutes(sender: UIStepper) {
    Settings.CountDownTimerMinutes = Int(sender.value)
  }

  @objc private func didChangeTimerType(sender: UISegmentedControl) {
    Settings.SavedTimerType = TimerType(rawValue: sender.selectedSegmentIndex)!
    self.tableView.reloadData()
  }

  // MARK: Tableview functions

  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.items.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return self.items.count
    }
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = self.items[indexPath.row]
    if item.didPress == nil {
      item.cell.selectionStyle = .none
    }
    if let cell = item.cell as? SettingsCell {
      cell.title = item.title
      cell.isEnabled = item.shouldEnable()
    } else {
      item.cell.textLabel?.text = item.title
    }

    return item.cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.tableView.deselectRow(at: indexPath, animated: true)
    self.items[indexPath.row].didPress?()
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let item = self.items[indexPath.row]
    return item.height
  }
}

class SettingsCell: UITableViewCell {
  private(set) var accessory = UIView()

  var isEnabled: Bool = true {
    didSet {
      self.accessory.isUserInteractionEnabled = isEnabled
      self.accessory.tintColor = isEnabled ? self.tintColor : .gray
      self.label.textColor = isEnabled ? .black : .gray
    }
  }
  private let label = UILabel()
  private let container = UIView()

  var title: String? {
    set(value) {
      self.label.text = value
    }
    get {
      return self.label.text
    }
  }

  convenience init() {
    self.init(style: .default, reuseIdentifier: nil)
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.container)
    self.container.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 16, bottom: 10, right: 0))
    }
    self.container.addSubview(self.label)
    self.label.snp.makeConstraints({ (make) in
      make.edges.equalToSuperview()
    })
  }

  convenience init(accessory: UIView) {
    self.init(style: .default, reuseIdentifier: nil)

    self.accessory = accessory
    self.container.addSubview(self.accessory)
    self.accessory.snp.makeConstraints { (make) in
      make.left.bottom.equalToSuperview()
      make.top.equalTo(self.container.snp.centerY)
    }
    self.label.snp.remakeConstraints({ (make) in
      make.right.top.left.equalToSuperview()
      make.bottom.equalTo(self.container.snp.centerY)
    })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
