//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import UIKit
import SnapKit
import SideMenu

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
  let topView = UIView()
  let bottomView = UIView()
  let totalTimerView = TotalTimerView()
  let restTimerView = RestTimerView()
  let clock = ClockView()

  let buttonStack = UIStackView()
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
    self.navigationController?.navigationBar.tintColor = .gray

    self.view.addSubview(self.clock)
    self.clock.snp.makeConstraints { (make) in
      make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(5)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(5)
    }

    // This is so taps for the rest timer are registered from anywhere in the topView
    self.restTimerView.addTapGestureRecognizer(to: self.topView)

    self.view.addSubview(self.topView)
    self.view.addSubview(self.bottomView)
    self.view.addSubview(self.totalTimerView)
    self.view.addSubview(self.restTimerView)

    self.buttonStack.spacing = 10
    self.view.addSubview(self.buttonStack)
    self.buttonStack.addArrangedSubview(self.playPauseButton)
    self.buttonStack.addArrangedSubview(self.refreshButton)

    self.remakeConstraintsBasedOnOrientation()

    self.playPauseButton.addTarget(self, action: #selector(self.startBtnTapped), for: .touchUpInside)
    self.refreshButton.addTarget(self, action: #selector(self.resetBtnTapped), for: .touchUpInside)

    let menu = UIImage(named: "menu")!.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0))
    let settings = UIBarButtonItem(image: menu, style: .plain, target: self, action: #selector(self.presentSettings))
    self.navigationItem.leftBarButtonItem = settings

    SideMenuManager.default.menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingTableViewController())
    SideMenuManager.default.menuLeftNavigationController!.sideMenuDelegate = self
    SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: .left)
    SideMenuManager.default.menuPresentMode = .viewSlideInOut

    // MARK: TimerView functions
    _ = self.restTimerView.addObserver { [weak self] (event, userInfo) in
      guard let strongSelf = self else { return }
      switch event {
      case .timerDidReset:
        strongSelf.totalTimerView.timerView.enlarge()
        strongSelf.tipsManager?.dismiss(forType: .stopRestTimer)
      case .timerDidStart:
        strongSelf.totalTimerView.timerView.soften()
        strongSelf.tipsManager?.dismiss(forType: .startRestTimer)
      case .timerDidFailToStart:
        if strongSelf.totalTimerView.timer.isPaused {
          strongSelf.playPauseButton.shake(withDirection: .rotate)
        } else {
          strongSelf.totalTimerView.timer.start()
          strongSelf.restTimerView.timer.start()
        }
      default: return
      }
    }

    _ = self.totalTimerView.addObserver { [weak self] (event, _) in
      guard let strongSelf = self else { return }
      switch event {
      case .timerDidReset:
        strongSelf.keepScreenFromLocking(false)
        strongSelf.restTimerView.isEnabled = false
        strongSelf.restTimerView.timer.reset()
        strongSelf.playPauseButton.currentButtonImage = .play
      case .timerDidStart:
        strongSelf.keepScreenFromLocking(true)
        strongSelf.restTimerView.isEnabled = true
        strongSelf.playPauseButton.currentButtonImage = .pause
      case .timerDidPause:
        strongSelf.keepScreenFromLocking(false)
        strongSelf.restTimerView.isEnabled = false
        strongSelf.restTimerView.timer.reset()
        strongSelf.playPauseButton.currentButtonImage = .play
      default: return
      }
    }

    self.showNextTip()
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    self.remakeConstraintsBasedOnOrientation()
  }

  func showNextTip() {
    guard let next = TipManager.next() else {
      self.tipsManager = nil
      return
    }
    if self.tipsManager == nil {
      self.tipsManager = TipManager()
      self.tipsManager!.onNextTip = { [weak self] in self?.showNextTip() }
    }
    switch next {
    case .startTimer:
      self.tipsManager!.show(inView: self.playPauseButton, forType: next, withinSuperView: self.view)
    case .startRestTimer, .stopRestTimer:
      self.tipsManager!.show(inView: self.restTimerView.timerView, forType: next, withinSuperView: self.restTimerView)
    case .settings:
      self.tipsManager!.show(forItem: self.navigationItem.leftBarButtonItem!, forType: next)
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
    if self.presentedViewController != nil {
      self.dismiss(animated: true, completion: nil)
    } else {
      self.resetTimers {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
      }
    }
    self.tipsManager?.dismiss(forType: .settings)
  }

  func keepScreenFromLocking(_ isIdleTimerDisabled: Bool) {
    UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabled
  }

  private func resetTimers(_ completion: (() -> ())? = nil) {
    print(#function)
    func reset() {
      self.totalTimerView.timer.reset()
      self.restTimerView.timer.reset()
      self.keepScreenFromLocking(false)
      completion?()
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

  private func remakeConstraintsBasedOnOrientation() {
    let isPortrait = UIDevice.current.orientation.isPortrait

    self.topView.snp.remakeConstraints { (make) in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      make.left.equalTo(self.view.safeAreaLayoutGuide)
      if isPortrait {
        make.right.equalTo(self.view.safeAreaLayoutGuide)
        make.bottom.equalTo(self.view.snp.centerY)
      } else {
        make.bottom.equalTo(self.clock.snp.top)
        make.right.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
      }
    }

    self.bottomView.snp.remakeConstraints { (make) in
      make.bottom.equalTo(self.clock.snp.top)
      make.right.equalTo(self.view.safeAreaLayoutGuide)
      if isPortrait {
        make.left.equalTo(self.view.safeAreaLayoutGuide)
        make.top.equalTo(self.topView.snp.bottom)
      } else {
        make.left.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
        make.top.equalTo(self.view.safeAreaLayoutGuide)
      }
    }

    self.totalTimerView.snp.remakeConstraints { (make) in
      make.width.equalTo(self.bottomView)
      make.centerX.equalTo(self.bottomView)
      if isPortrait {
        make.top.equalTo(self.bottomView)
      } else {
        make.centerY.equalTo(self.bottomView)
      }
    }

    self.restTimerView.snp.remakeConstraints { (make) in
      make.width.equalTo(self.topView)
      make.centerX.equalTo(self.topView)
      if isPortrait {
        make.centerY.equalTo(self.topView)
      } else {
        // FIXME: ideally, restTimerView.timerView.centerY = totalTimerView.timerView.centerY
        make.centerY.equalTo(self.totalTimerView.timerView).offset(25)
      }
    }

    self.buttonStack.snp.remakeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
      if isPortrait {
        make.top.equalTo(self.totalTimerView.snp.bottom).offset(25)
      } else {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(5)
      }
    }
  }
}

extension ViewController: UISideMenuNavigationControllerDelegate {

  func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
    print("SideMenu Appearing! (animated: \(animated))")
  }

  func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
    print("SideMenu Appeared! (animated: \(animated))")
  }

  func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
    print("SideMenu Disappearing! (animated: \(animated))")
    self.restTimerView.updateStepper()
    self.totalTimerView.updateCountTimer()
  }

  func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
    print("SideMenu Disappeared! (animated: \(animated))")
    self.showNextTip()
  }

}
