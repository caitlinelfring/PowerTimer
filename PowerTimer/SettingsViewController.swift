//
//  SettingsViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class SettingTableViewController: UITableViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  struct Item {
    var title: String
    var cell: UITableViewCell
    var didPress: (() -> ())?

    init(title: String, cell: UITableViewCell = UITableViewCell(), didPress: (() -> ())? = nil) {
      self.title = title
      self.cell = cell
      self.didPress = didPress
    }
  }

  convenience init() {
    self.init(style: .plain)
  }

  private var items = [Item]()
  private let restCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

  override init(style: UITableViewStyle) {
    super.init(style: style)

    self.restCell.accessoryView = restStepper()
    self.restCell.textLabel?.text = "Rest Time"
    self.updateRestCellSubtitle()
    self.items.append(Item(title: "Rest Time", cell: self.restCell))

    let timerTypeCell = UITableViewCell()
    timerTypeCell.accessoryView = timerTypeControl()
    self.items.append(Item(title: "Timer Type", cell: timerTypeCell))

    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.tableHeaderView = UIView()
    self.tableView.tableFooterView = UIView()

    self.navigationItem.title = "SETTINGS"
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.tintColor = .black
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func restStepper() -> UIStepper {
    let stepper = UIStepper()
    stepper.minimumValue = 1
    stepper.maximumValue = 20
    stepper.stepValue = 1
    stepper.wraps = false
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
  func updateRestCellSubtitle() {
    self.restCell.detailTextLabel?.text = "\(Settings.RestTimerMinutes) minutes"
  }

  @objc func didChangeRestMinutes(sender: UIStepper) {
    Settings.RestTimerMinutes = Int(sender.value)
    self.updateRestCellSubtitle()
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
  }
}
