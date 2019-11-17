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
import SlideMenuControllerSwift
import MessageUI
import StoreKit
import PTTimer

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

  var overrideStatusBarStyle: Bool = false
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.overrideStatusBarStyle ? .default : super.preferredStatusBarStyle
  }

  convenience init() {
    self.init(style: .plain)
  }

  private var canChangeTimerType: Bool {
    let nav = (self.parent as! SlideMenuController).mainViewController as! UINavigationController
    let parentTimer = (nav.children.first! as! TimerViewController).totalTimerView.timer!
    return parentTimer.state == .reset
  }

  private var items = [Item]()
  private var secondItems = [Item]()
  private let sections = ["Timer", "General"]
  private var currentTip: EasyTipView?
  let header = UIView()
  let versionLabel = UILabel()

  override init(style: UITableView.Style) {
    super.init(style: style)

    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    self.versionLabel.textAlignment = .center
    self.versionLabel.textColor = UIColor.lightGray
    self.versionLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    self.versionLabel.backgroundColor = self.tableView.backgroundColor ?? .white
    self.versionLabel.text = "Version: \(version)"

    let timerTypeCell = SettingsCell(accessory: timerTypeControl())
    var ttcItem = Item(title: "Timer Type", height: 80, cell: timerTypeCell)
    ttcItem.shouldEnable = { return self.canChangeTimerType }
    ttcItem.didPress = {
      if !self.canChangeTimerType {
        var prefs = EasyTipView.Preferences()
        prefs.animating.dismissOnTap = true
        self.currentTip?.dismiss()
        self.currentTip = EasyTipView(text: "Reset the current timer to change this.", preferences: prefs, delegate: nil)
        self.currentTip!.show(animated: true, forView: timerTypeCell.accessory, withinSuperview: self.view)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
          self.currentTip?.dismiss()
        })
      }
    }
    self.items.append(ttcItem)

    let countDownTimerMinutesCell = SettingsCell(accessory: countDownTimerStepper())
    var cdt = Item(title: "Countdown Minutes", height: 80, cell: countDownTimerMinutesCell)
    cdt.shouldEnable = { return Settings.SavedTimerType == .down && self.canChangeTimerType }
    self.items.append(cdt)

    #if DEBUG
    self.items.append(Item(title: "Reset Intro Tips", didPress: {
      Settings.IntroTips.reset()
    }))
    #endif

    let soundCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    soundCell.accessoryView = soundOnOffSwitch()
    self.items.append(Item(title: "Rest timer sounds", cell: soundCell))

    let prepareCountdownCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    prepareCountdownCell.accessoryView = prepareCountdownSwitch()
    self.items.append(Item(title: "5s pre-start timer", cell: prepareCountdownCell))

//    TODO Add this in another version
//    let themeCell = SettingsCell(accessory: themeControl())
//    self.items.append(Item(title: "Theme", height: 80, cell: themeCell))

    let contactCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    self.secondItems.append(Item(title: "Contact", cell: contactCell, didPress: {

      Tracking.log("settings.contact", parameters: ["mail_configured": MFMailComposeViewController.canSendMail()])

      let email = "support@powertimer.app"

      if MFMailComposeViewController.canSendMail() {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("PowerTimer App")
        mail.setToRecipients([email])
        if let deviceID = Settings.DeviceID {
          mail.setMessageBody("<br><br><br><br><br><br><hr><strong>Technical info for developer, please don't delete</strong><hr><p>ID: \(deviceID)</p>", isHTML: true)
        }
        self.present(mail, animated: true, completion: {
          self.overrideStatusBarStyle = true
          self.setNeedsStatusBarAppearanceUpdate()
        })
      } else {
        let alert = UIAlertController(title: "Mail not configured", message: "But you can still send an email to '\(email)'", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    }))

    self.secondItems.append(Item(title: "Rate PowerTimer", didPress: {
      Tracking.log("settings.rating")
      let url = "itms-apps://itunes.apple.com/us/app/powertimer-app/id1440431695?mt=8&action=write-review"
      UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }))

    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.tableFooterView = UIView()
    self.tableView.estimatedRowHeight = 44
    self.tableView.rowHeight = 44
    self.tableView.sectionHeaderHeight = 30
    if #available(iOS 13.0, *) {
      self.tableView.overrideUserInterfaceStyle = .light
    }
    self.navigationItem.title = "SETTINGS"

    // This is the area the is under the status bar
    self.header.backgroundColor = Colors.backgroundColor
    self.view.addSubview(self.header)
    self.view.bringSubviewToFront(self.header)
    self.header.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalTo(self.view) // extend above the view so it's still black when you try to scroll
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
    }

    self.view.addSubview(self.versionLabel)
    self.versionLabel.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.centerX.equalToSuperview()
      make.width.equalToSuperview()
    }
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    // Makes sure these views are above the section headers
    self.view.bringSubviewToFront(self.header)
    self.view.bringSubviewToFront(self.versionLabel)
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
    self.header.isHidden = UIApplication.shared.isStatusBarHidden
    self.tableView.reloadData()
  }

  func countDownTimerStepper() -> ValueStepper {
    let stepper = SettingsCountDownTimerStepper()
    stepper.labelTextColor = self.view.tintColor
    stepper.value = Double(Settings.CountDownTimerMinutes)
    stepper.addTarget(self, action: #selector(self.didChangeCountDownTimerMinutes), for: .valueChanged)
    return stepper
  }

  private func timerTypeControl() -> UISegmentedControl {
    let segmentControl = UISegmentedControl(items: PTTimerType.available.map { $0.rawValue })
    segmentControl.addTarget(self, action: #selector(self.didChangeTimerType), for: .valueChanged)
    segmentControl.selectedSegmentIndex = PTTimerType.available.index(of: Settings.SavedTimerType) ?? 0
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
    Tracking.log("settings.theme.changed", parameters: ["theme": Settings.currentTheme.description])

    UIView.animate(withDuration: 0.5) {
      self.header.backgroundColor = Colors.backgroundColor
      let nav = (self.parent as! SlideMenuController).mainViewController as! UINavigationController
      let parent = nav.children.first! as! TimerViewController
      parent.setColors()
    }
  }

  private func soundOnOffSwitch() -> UISwitch {
    let soundSwitch = UISwitch()
    soundSwitch.setOn(Settings.Sound.playSoundAlert, animated: false)
    soundSwitch.addTarget(self, action: #selector(self.soundSwitchDidChange), for: .valueChanged)
    return soundSwitch
  }

  @objc func soundSwitchDidChange(sender: UISwitch) {
    Settings.Sound.playSoundAlert = sender.isOn
    Tracking.log("settings.sound.changed", parameters: ["state": sender.isOn])

  }

  @objc func didChangeCountDownTimerMinutes(sender: UIStepper) {
    Settings.CountDownTimerMinutes = Int(sender.value)
  }

  @objc private func didChangeTimerType(sender: UISegmentedControl) {
    Settings.SavedTimerType = PTTimerType(rawValue: PTTimerType.available[sender.selectedSegmentIndex].rawValue)!
    Tracking.log("settings.timer.changed", parameters: ["type": Settings.SavedTimerType.rawValue])
    self.tableView.reloadData()
  }

  private func prepareCountdownSwitch() -> UISwitch {
    let uiswitch = UISwitch()
    uiswitch.setOn(Settings.prepareCountdown, animated: false)
    uiswitch.addTarget(self, action: #selector(self.prepareCountdownDidChange), for: .valueChanged)
    return uiswitch
  }

  @objc private func prepareCountdownDidChange(sender: UISwitch) {
    Settings.prepareCountdown = sender.isOn
    Tracking.log("settings.prepareCountdown.changed", parameters: ["state": sender.isOn])
  }

  // MARK: Tableview functions

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.sections[section]
  }
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return self.items.count
    } else if section == 1 {
      return self.secondItems.count
    }
    return 0
  }

  func getItem(at indexPath: IndexPath) -> Item {
    if indexPath.section == 0 {
      return self.items[indexPath.row]
    } else {
      return self.secondItems[indexPath.row]
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = self.getItem(at: indexPath)

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
    self.getItem(at: indexPath).didPress?()
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let item = self.getItem(at: indexPath)
    return item.height
  }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    if let err = error { print(err) }
    controller.dismiss(animated: true) {
      self.overrideStatusBarStyle = false
      self.setNeedsStatusBarAppearanceUpdate()
    }
  }
}
