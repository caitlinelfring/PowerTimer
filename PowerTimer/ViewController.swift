//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import UIKit
import SnapKit

// Since I'm not subclassing UINavigationController, this is the simplist way
// to get the status bar styles working correctly in a navigation stack
// https://stackoverflow.com/questions/19108513/uistatusbarstyle-preferredstatusbarstyle-does-not-work-on-ios-7
extension UINavigationController {
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    if let last = self.viewControllers.last {
      return last.preferredStatusBarStyle
    }
    return super.preferredStatusBarStyle
  }
}

class ViewController: UIViewController {
  let totalTimerView = TotalTimerView()
  let restTimerView = RestTimerView()

  let playPauseButton = PlayPauseButton()
  let refreshButton = RefreshButton()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  var tipsManager: TipManager?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    self.navigationController?.navigationBar.tintColor = .white

    let topLayoutGuide = UIView()
    self.view.addSubview(topLayoutGuide)
    topLayoutGuide.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(self.view.snp.centerY)
    }

    let bottomLayoutGuide = UIView()
    self.view.addSubview(bottomLayoutGuide)
    bottomLayoutGuide.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(topLayoutGuide.snp.bottom)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }

    self.view.addSubview(self.restTimerView)
    self.restTimerView.snp.makeConstraints { (make) in
      make.top.left.right.equalTo(topLayoutGuide)
      make.bottom.equalTo(topLayoutGuide)
    }

    self.view.addSubview(self.totalTimerView)
    self.totalTimerView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(bottomLayoutGuide.snp.top)
    }

    let buttonStack = UIStackView()
    buttonStack.spacing = 10
    self.view.addSubview(buttonStack)
    buttonStack.snp.makeConstraints { (make) in
      make.top.equalTo(self.totalTimerView.snp.bottom).offset(25)
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
    }

    buttonStack.addArrangedSubview(self.playPauseButton)
    buttonStack.addArrangedSubview(self.refreshButton)

    self.playPauseButton.addTarget(self, action: #selector(self.startBtnTapped), for: .touchUpInside)
    self.refreshButton.addTarget(self, action: #selector(self.resetBtnTapped), for: .touchUpInside)

    let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.presentSettings))
    self.navigationItem.rightBarButtonItem = settings

    let clock = ClockView()
    self.view.addSubview(clock)
    clock.snp.makeConstraints { (make) in
      make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(5)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(5)
    }

    self.restTimerView.onTimerStart = { [weak self] in
      self?.totalTimerView.timerView.soften()
      self?.tipsManager?.dismiss(forType: .startRestTimer)
    }
    self.restTimerView.onTimerReset = { [weak self] in
      self?.totalTimerView.timerView.enlarge()
      self?.tipsManager?.dismiss(forType: .stopRestTimer)
    }
    self.restTimerView.onTimerStartAttemptedWhileDisabled = { [weak self] in
      guard let strongSelf = self else { return }
      if strongSelf.totalTimerView.timer.isPaused {
        strongSelf.playPauseButton.shake(withDirection: .rotate)
      } else {
        strongSelf.totalTimerView.timer.start()
        strongSelf.restTimerView.timer.start()
      }
    }

    self.totalTimerView.onTimerReset = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(false)
      strongSelf.restTimerView.isEnabled = false
      strongSelf.restTimerView.timer.reset()
      strongSelf.playPauseButton.currentButtonImage = .play
    }
    self.totalTimerView.onTimerStart = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(true)
      strongSelf.restTimerView.isEnabled = true
      strongSelf.playPauseButton.currentButtonImage = .pause
    }
    self.totalTimerView.onTimerPaused = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(false)
      strongSelf.restTimerView.isEnabled = false
      strongSelf.restTimerView.timer.reset()
      strongSelf.playPauseButton.currentButtonImage = .play
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.tintColor = .white
    self.restTimerView.updateStepper()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.showNextTip()
  }

  func showNextTip() {
    guard let next = TipManager.next() else {
      self.tipsManager = nil
      return
    }
    if self.tipsManager == nil {
      self.tipsManager = TipManager()
      self.tipsManager!.onNextTip = self.showNextTip
    }
    switch next {
    case .startTimer:
      self.tipsManager!.show(inView: self.playPauseButton, forType: next, withinSuperView: self.view)
    case .startRestTimer, .stopRestTimer:
      self.tipsManager!.show(inView: self.restTimerView, forType: next, withinSuperView: self.view)
    case .settings:
      self.tipsManager!.show(forItem: self.navigationItem.rightBarButtonItem!, forType: next)
    }

  }

  @objc private func startBtnTapped(sender: PlayPauseButton) {
    print(#function)
    if sender.isPlay {
      self.totalTimerView.timer.start()
      self.tipsManager?.dismiss(forType: .startTimer)
    } else {
      self.totalTimerView.timer.pause()
    }
  }

  @objc private func resetBtnTapped(sender: ImageButton) {
    print(#function)
    self.resetTimers()
  }

  @objc private func presentSettings() {
    let settingsVC = SettingTableViewController()
    if let nav = self.navigationController {
      nav.pushViewController(settingsVC, animated: true)
    } else {
      self.present(settingsVC, animated: true, completion: nil)
    }
    self.tipsManager?.dismiss(forType: .settings)
  }

  func keepScreenFromLocking(_ isIdleTimerDisabled: Bool) {
    UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabled
  }

  private func resetTimers() {
    print(#function)
    func reset() {
      self.totalTimerView.timer.reset()
      self.restTimerView.timer.reset()
      self.keepScreenFromLocking(false)
    }
    if !self.totalTimerView.timer.isActive {
      reset()
      return
    }
    let alert = UIAlertController(title: "Are you sure you want to reset the timer?", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
      reset()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}
