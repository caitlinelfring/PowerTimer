//
//  PrepareTimerViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 9/22/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class PrepareTimerViewController: UIViewController {
  var completion: (() -> ())?

  static let seconds = 5

  private let modalView = UIView()
  private let timer = CountDownTimer(seconds: seconds)

  private let timerView = UILabel()

  convenience init(completion: (() -> ())?) {
    self.init()
    self.completion = completion
    self.modalPresentationStyle = .overCurrentContext
  }
  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .clear

    let blur = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: blur)
    self.view.addSubview(blurView)
    blurView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }

    self.timerView.text = "\(self.timer.currentSeconds)"
    // TODO: Better font size based on frame?
    self.timerView.font = TimerView.Constants.Active.font.withSize(Settings.minScreenDimension)
    self.timerView.textColor = .green // TODO: Better green
    self.timerView.textAlignment = .center
    self.view.addSubview(self.timerView)
    self.timerView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
    }

    self.timer.delegate = self
    self.timer.start()
  }
}


extension PrepareTimerViewController: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    self.timerView.text = "\(seconds)"
  }

  func onReset() {}
  func onStart() {}
  func onPaused() {
    self.dismiss(animated: true, completion: self.completion)
  }
}
