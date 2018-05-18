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

class SettingTableViewController: UITableViewController {
  struct Item {
    var title: String
    var cell: UITableViewCell
    var didPress: (() -> ())?
    var height: CGFloat

    init(title: String, height: CGFloat = UITableViewAutomaticDimension, cell: UITableViewCell = UITableViewCell(), didPress: (() -> ())? = nil) {
      self.title = title
      self.height = height
      self.cell = cell
      self.didPress = didPress
    }
  }

  convenience init() {
    self.init(style: .plain)
  }

  private var items = [Item]()

  override init(style: UITableViewStyle) {
    super.init(style: style)

    let restCell = SettingsAccessoryViewCell(accessory: restStepper())
    self.items.append(Item(title: "Rest Time", height: 83, cell: restCell))

    let timerTypeCell = SettingsAccessoryViewCell(accessory: timerTypeControl())
    self.items.append(Item(title: "Timer Type", height: 83, cell: timerTypeCell))

    let resetTipsCell = UITableViewCell()
    self.items.append(Item(title: "Reset Intro Tips", cell: resetTipsCell, didPress: {
      Settings.IntroTips.reset()
      self.navigationController?.popViewController(animated: true)
    }))

    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.tableHeaderView = UIView()
    self.tableView.tableFooterView = UIView()
    self.tableView.estimatedRowHeight = 44
    self.tableView.rowHeight = UITableViewAutomaticDimension

    self.navigationItem.title = "SETTINGS"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func restStepper() -> ValueStepper {
    // TODO: Fork this repo and make it so I can subclass ValueStepper
    // in order to store these defaults so they aren't repeated in the view controller and settings
    let stepper = ValueStepper()
    stepper.minimumValue = 1
    stepper.maximumValue = 20
    stepper.stepValue = 1
    stepper.autorepeat = false
    stepper.tintColor = self.view.tintColor
    stepper.labelTextColor = self.view.tintColor
    stepper.backgroundLabelColor = .clear
    stepper.backgroundColor = .clear
    stepper.backgroundButtonColor = .clear
    stepper.highlightedBackgroundColor = .gray
    stepper.value = Double(Settings.RestTimerMinutes)
    stepper.addTarget(self, action: #selector(self.didChangeRestMinutes), for: .valueChanged)
    return stepper
  }

  private func timerTypeControl() -> UISegmentedControl {
    let segmentControl = UISegmentedControl(items: TimerType.available.map { $0.description })
    segmentControl.addTarget(self, action: #selector(self.didChangeTimerType), for: .valueChanged)
    segmentControl.selectedSegmentIndex = Settings.SavedTimerType.rawValue

    // countDown not available yet
    segmentControl.setEnabled(false, forSegmentAt: TimerType.available.index(where: { $0 == TimerType.countDown })!)

    return segmentControl
  }

  @objc func didChangeRestMinutes(sender: UIStepper) {
    Settings.RestTimerMinutes = Int(sender.value)
  }

  @objc private func didChangeTimerType(sender: UISegmentedControl) {
    Settings.SavedTimerType = TimerType(rawValue: sender.selectedSegmentIndex)!
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
    item.cell.textLabel?.text = item.title
    return item.cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.tableView.deselectRow(at: indexPath, animated: true)
    self.items[indexPath.row].didPress?()
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.items[indexPath.row].height
  }
}

class SettingsAccessoryViewCell: UITableViewCell {
  private var accessory = UIView()

  convenience init(accessory: UIView) {
    self.init(style: .default, reuseIdentifier: nil)

    self.textLabel!.snp.makeConstraints({ (make) in
      make.top.equalToSuperview().offset(10)
      make.left.equalToSuperview().offset(16)
    })

    self.accessory = accessory
    self.contentView.addSubview(self.accessory)
    self.accessory.snp.makeConstraints { (make) in
      make.left.equalToSuperview().inset(16)
      make.top.equalTo(self.textLabel!.snp.bottom).offset(10)
      make.bottom.equalToSuperview().inset(10)
    }
  }
}
