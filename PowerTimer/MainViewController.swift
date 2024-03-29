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
  private var settingsVC = SettingTableViewController(style: .grouped)

  convenience init() {
    self.init(nibName: nil, bundle: nil)
    // These two are for stopping the Slide menu from scaling the timers down to 0.96 when
    // the menu opens.
    // TODO: I think the scaling is a cool effect, find out why the timer animations being weird
    SlideMenuOptions.contentViewDrag = false
    SlideMenuOptions.contentViewScale = 1
    SlideMenuOptions.hideStatusBar = false
    SlideMenuOptions.simultaneousGestureRecognizers = false
    self.mainViewController = UINavigationController(rootViewController: self.timerVC)
    self.delegate = self.timerVC
    self.leftViewController = self.settingsVC
    self.initView()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.startLoadingAnimation()
  }

  private func startLoadingAnimation() {
    let maskBgView = UIView(frame: self.view.frame)
    maskBgView.backgroundColor = .black

    // Label should match the launch screen label
    let label = PowerTimerLogo(font: UIFont(name: "AvenirNext-Medium", size: 55)!)
    label.shadowOffset = CGSize(width: 4, height: 4)

    maskBgView.addSubview(label)
    label.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalTo(306)
    }
    self.view.addSubview(maskBgView)
    self.view.bringSubviewToFront(maskBgView)
    maskBgView.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.edges.equalToSuperview()
    }
    UIView.animate(withDuration: 0.25, delay: 0.5, options: UIView.AnimationOptions.curveEaseInOut, animations: {
      label.alpha = 0.0
    }, completion: { finished in
      UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
        maskBgView.alpha = 0.0
      }, completion: { finished in
        self.timerVC.setNeedsStatusBarAppearanceUpdate()
        maskBgView.removeFromSuperview()
      })
    })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
