//
//  ViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import UIKit
import SnapKit
import SlideMenuControllerSwift

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

class TimerViewController: UIViewController {
  let topView = UIView()
  let bottomView = UIView()
  let totalTimerView = TotalTimerView()
  let restTimerView = RestTimerView()
  let clock = ClockView()

  let buttonStack = UIStackView()
  let playPauseButton = PlayPauseButton()
  let resetButton = ResetButton()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return Settings.currentTheme == .dark ? .lightContent : .default
    // default: intended for use on light backgrounds
    // lightContent: intended for use on dark backgrounds
  }

  convenience init() {
    self.init(nibName: nil, bundle: nil)
    let menu = UIImage(named: "menu")!.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0))
    self.addLeftBarButtonWithImage(menu)
  }

  var tipsManager: TipManager?

  func setColors() {
    print(#function)
    self.view.backgroundColor = Colors.backgroundColor
    self.totalTimerView.updateTimerColor()
    self.restTimerView.updateTimerColor()
    self.navigationController?.view.backgroundColor = Colors.backgroundColor
    self.navigationController?.navigationBar.tintColor = Colors.navigationBarTintColor
    self.playPauseButton.color = Colors.buttonColor
    self.resetButton.color = Colors.buttonColor
    self.setNeedsStatusBarAppearanceUpdate()
    UIApplication.shared.keyWindow?.backgroundColor = Colors.backgroundColor
    self.view.layoutSubviews()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setColors()
    // Make the nav bar transparent
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true

    self.navigationItem.titleView = {
      guard let nav = self.navigationController else {
        return nil
      }

      let fontSize = min(Settings.minScreenDimension * 0.06, nav.navigationBar.frame.size.height)
      return PowerTimerLogo(kerning: 2, font: UIFont(name: "AvenirNext-DemiBold", size: fontSize)!)
    }()


    self.view.addSubview(self.clock)
    self.clock.snp.makeConstraints { (make) in
      make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(5)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(5)
    }

    self.view.addSubview(self.topView)
    self.view.addSubview(self.bottomView)
    self.view.addSubview(self.totalTimerView)

    self.topView.addSubview(self.restTimerView)
    // This is so taps for the rest timer are registered from anywhere in the topView
    self.restTimerView.addTapGestureRecognizer(to: self.topView)

    self.buttonStack.spacing = 10
    self.view.addSubview(self.buttonStack)
    self.buttonStack.addArrangedSubview(self.playPauseButton)
    self.buttonStack.addArrangedSubview(self.resetButton)

    self.remakeConstraintsBasedOnOrientation()

    self.playPauseButton.addTarget(self, action: #selector(self.startBtnTapped), for: .touchUpInside)
    self.resetButton.addTarget(self, action: #selector(self.resetBtnTapped), for: .touchUpInside)

    self.setupTimerObservers()

    StoreReviewHelper.checkAndAskForReview()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.showNextTip()
  }

  private func setupTimerObservers() {
    // MARK: TimerView functions
    _ = self.restTimerView.addObserver { [weak self] (event, userInfo) in
      guard let strongSelf = self else { return }
      switch event {
      case .timerDidReset:
        if strongSelf.totalTimerView.timer.state == .paused {
          strongSelf.totalTimerView.timerView.state = .paused
        } else {
          strongSelf.totalTimerView.timerView.state = .active
        }
        strongSelf.tipsManager?.dismiss(forType: .stopRestTimer)
      case .timerDidStart:
        strongSelf.totalTimerView.timerView.state = .inactive
        strongSelf.tipsManager?.dismiss(forType: .startRestTimer)
      case .timerDidFailToStart:
        if strongSelf.totalTimerView.timer.state == .paused {
          let feedback = UINotificationFeedbackGenerator()
          feedback.prepare()
          feedback.notificationOccurred(.warning)
          strongSelf.playPauseButton.shake(withDirection: .rotate)
          Tracking.log("timer.rest.failedToStart")
        } else {
          strongSelf.totalTimerView.timer.start()
          strongSelf.restTimerView.timer.start()
          Tracking.log("timer.rest.started")
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
        strongSelf.resetButton.isEnabled = true
      case .timerDidStart:
        strongSelf.keepScreenFromLocking(true)
        strongSelf.restTimerView.isEnabled = true
        strongSelf.playPauseButton.currentButtonImage = .pause
        strongSelf.resetButton.isEnabled = false
      case .timerDidPause:
        strongSelf.keepScreenFromLocking(false)
        strongSelf.restTimerView.isEnabled = false
        strongSelf.restTimerView.timer.reset()
        strongSelf.playPauseButton.currentButtonImage = .play
        strongSelf.resetButton.isEnabled = true
      default: return
      }
    }
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
      self.animateTopViewBorder()
    case .settings:
      self.tipsManager!.show(forItem: self.navigationItem.leftBarButtonItem!, forType: next)
    }

  }

  @objc private func startBtnTapped(sender: PlayPauseButton) {
    print(#function, "isPlay:", sender.isPlay)
    if sender.isPlay {
      let start = {
        self.totalTimerView.timer.start()
        self.tipsManager?.dismiss(forType: .startTimer)
        Tracking.log("timer.total.started")
      }

      if self.totalTimerView.timer.state == .reset && Settings.prepareCountdown {
        // Only show the PrepareTimerViewController if the timer is starting fresh
        self.present(PrepareTimerViewController(completion: start), animated: true, completion: nil)
      } else {
        start()
      }
    } else {
      self.totalTimerView.timer.pause()
      Tracking.log("timer.total.paused")
    }
  }

  @objc private func resetBtnTapped(sender: ImageButton) {
    print(#function)
    self.resetTimers()
    Tracking.log("timer.total.reset")
  }

  func keepScreenFromLocking(_ isIdleTimerDisabled: Bool) {
    UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabled
  }

  private func resetTimers() {
    self.totalTimerView.timer.reset()
    self.restTimerView.timer.reset()
    self.keepScreenFromLocking(false)
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
      make.height.equalTo(min(100, Settings.minScreenDimension * 0.15))
      if isPortrait {
        make.top.equalTo(self.totalTimerView.snp.bottom).offset(25)
      } else {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(5)
      }
    }
  }

  func animateTopViewBorder() {
    let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
    let borderWidth: CGFloat = 2
    animation.fromValue = 0
    animation.toValue = borderWidth
    animation.duration = 0.75
    animation.autoreverses = true
    animation.repeatCount = 3
    animation.isRemovedOnCompletion = true
    animation.delegate = self

    self.topView.layer.add(animation, forKey: nil)
    self.topView.layer.borderWidth = borderWidth
    self.topView.layer.cornerRadius = 10
    self.topView.layer.borderColor = UIColor.red.cgColor
  }
}

extension TimerViewController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag {
      self.topView.layer.borderColor = nil
    }
  }
}
extension TimerViewController: SlideMenuControllerDelegate {
  func leftWillOpen() {
    print("SlideMenuControllerDelegate: leftWillOpen")
    self.tipsManager?.dismiss(forType: .settings)
  }

  func leftDidOpen() {
    print("SlideMenuControllerDelegate: leftDidOpen")
  }

  func leftWillClose() {
    print("SlideMenuControllerDelegate: leftWillClose")
    self.restTimerView.updateStepper()
    if self.totalTimerView.timer.state != .running && self.totalTimerView.timer.state != .paused {
      self.totalTimerView.updateCountTimer()
    }
  }

  func leftDidClose() {
    print("SlideMenuControllerDelegate: leftDidClose")
  }
}

