//
//  MainViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 8/11/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import SlideMenuControllerSwift

class MainViewController: SlideMenuController {

  private var timerVC = TimerViewController()
  private var settingsVC = SettingTableViewController()

  convenience init() {
    self.init(nibName: nil, bundle: nil)
    SlideMenuOptions.hideStatusBar = false
    self.mainViewController = UINavigationController(rootViewController: self.timerVC)
    self.delegate = self.timerVC
    self.leftViewController = self.settingsVC
    self.initView()
  }

//  func tog

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func startAnimationFinished() {
    self.timerVC.overrideStatusBar = nil
    self.timerVC.setNeedsStatusBarAppearanceUpdate()
  }
}
