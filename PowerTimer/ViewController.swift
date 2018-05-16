//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

// TODO
// Light/dark theme

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

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = UIColor.clear
    self.navigationController?.navigationBar.tintColor = .white

    let topLayoutGuide = UILayoutGuide()
    self.view.addLayoutGuide(topLayoutGuide)
    topLayoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    topLayoutGuide.bottomAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

    let bottomLayoutGuide = UILayoutGuide()
    self.view.addLayoutGuide(bottomLayoutGuide)
    bottomLayoutGuide.topAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    bottomLayoutGuide.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

    self.view.addSubview(self.restTimerView)
    self.restTimerView.translatesAutoresizingMaskIntoConstraints = false
    self.restTimerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.restTimerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.restTimerView.centerYAnchor.constraint(equalTo: topLayoutGuide.centerYAnchor).isActive = true
    self.restTimerView.onTimerStart = { [weak self] in
      self?.totalTimerView.timerView.soften()
    }
    self.restTimerView.onTimerReset = { [weak self] in
      self?.totalTimerView.timerView.enlarge()
    }

    self.view.addSubview(self.totalTimerView)
    self.totalTimerView.translatesAutoresizingMaskIntoConstraints = false
    self.totalTimerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    self.totalTimerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.totalTimerView.topAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true

    self.totalTimerView.resetTimerRequested = self.resetTimers
    self.totalTimerView.onTimerReset = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(false)
      strongSelf.restTimerView.isEnabled = false
      strongSelf.restTimerView.timer.reset()
    }
    self.totalTimerView.onTimerStart = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(true)
      strongSelf.restTimerView.isEnabled = true
    }
    self.totalTimerView.onTimerPaused = { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.keepScreenFromLocking(false)
      strongSelf.restTimerView.isEnabled = false
      strongSelf.restTimerView.timer.reset()
    }

    let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.presentSettings))
    self.navigationItem.rightBarButtonItem = settings
  }

  override func viewWillAppear(_ animated: Bool) {
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
