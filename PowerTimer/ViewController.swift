//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import UIKit

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

  let playButton = PlayButton()
  let pauseButton = PauseButton()
  let refreshButton = RefreshButton()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  var tipsManager: TipManager?

  override func viewDidLoad() {
    super.viewDidLoad()
    Settings.IntroTips.reset() // TEMP FOR TESTING
    self.view.backgroundColor = .black

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    self.navigationController?.navigationBar.tintColor = .white

    let topLayoutGuide = UILayoutGuide()
    self.view.addLayoutGuide(topLayoutGuide)
    topLayoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    topLayoutGuide.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true

    let bottomLayoutGuide = UILayoutGuide()
    self.view.addLayoutGuide(bottomLayoutGuide)
    bottomLayoutGuide.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    bottomLayoutGuide.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

    self.view.addSubview(self.restTimerView)
    self.restTimerView.translatesAutoresizingMaskIntoConstraints = false
    self.restTimerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.restTimerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.restTimerView.centerYAnchor.constraint(equalTo: topLayoutGuide.centerYAnchor, constant: -UIScreen.main.bounds.height / 8).isActive = true
    self.restTimerView.onTimerStart = { [weak self] in
      self?.totalTimerView.timerView.soften()
      self?.tipsManager?.dismiss(forType: .startRestTimer)
    }
    self.restTimerView.onTimerReset = { [weak self] in
      self?.totalTimerView.timerView.enlarge()
      self?.tipsManager?.dismiss(forType: .stopRestTimer)
    }

    self.view.addSubview(self.totalTimerView)
    self.totalTimerView.translatesAutoresizingMaskIntoConstraints = false
    self.totalTimerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.totalTimerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.totalTimerView.centerYAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
    self.totalTimerView.onTimerReset = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(false)
      strongSelf.restTimerView.isEnabled = false
      strongSelf.restTimerView.timer.reset()
      strongSelf.updateButtonStates()
    }
    self.totalTimerView.onTimerStart = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(true)
      strongSelf.restTimerView.isEnabled = true
      strongSelf.updateButtonStates()
    }
    self.totalTimerView.onTimerPaused = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(false)
      strongSelf.restTimerView.isEnabled = false
      strongSelf.restTimerView.timer.reset()
      strongSelf.updateButtonStates()
    }

    let buttonStack = UIStackView()
    buttonStack.spacing = 10
    self.view.addSubview(buttonStack)
    buttonStack.translatesAutoresizingMaskIntoConstraints = false
    buttonStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    buttonStack.topAnchor.constraint(equalTo: self.totalTimerView.bottomAnchor, constant: 25).isActive = true
    buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
    buttonStack.addArrangedSubview(self.playButton)
    buttonStack.addArrangedSubview(self.pauseButton)
    buttonStack.addArrangedSubview(self.refreshButton)

    self.playButton.addTarget(self, action: #selector(self.startBtnTapped), for: .touchUpInside)
    self.pauseButton.addTarget(self, action: #selector(self.pauseBtnTapped), for: .touchUpInside)
    self.refreshButton.addTarget(self, action: #selector(self.resetBtnTapped), for: .touchUpInside)

    self.updateButtonStates()

    let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.presentSettings))
    self.navigationItem.rightBarButtonItem = settings

    let clock = ClockView()
    self.view.addSubview(clock)
    clock.translatesAutoresizingMaskIntoConstraints = false
    clock.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5).isActive = true
    clock.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true

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
      self.tipsManager!.show(inView: self.playButton, forType: next, withinSuperView: self.view)
    case .startRestTimer, .stopRestTimer:
      self.tipsManager!.show(inView: self.restTimerView, forType: next, withinSuperView: self.view)
    case .settings:
      self.tipsManager!.show(forItem: self.navigationItem.rightBarButtonItem!, forType: next)
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.tintColor = .white
  }

  func updateButtonStates() {
    self.playButton.isHidden = self.totalTimerView.timer.isActive
    self.pauseButton.isHidden = !self.playButton.isHidden
  }

  @objc private func startBtnTapped(sender: ImageButton) {
    print(#function)
    self.totalTimerView.timer.start()
    self.updateButtonStates()
    self.tipsManager?.dismiss(forType: .startTimer)
  }

  @objc private func pauseBtnTapped(sender: ImageButton) {
    print(#function)
    self.totalTimerView.timer.pause()
    self.updateButtonStates()
  }

  @objc private func resetBtnTapped(sender: ImageButton) {
    print(#function)
    self.resetTimers()
    self.updateButtonStates()
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
