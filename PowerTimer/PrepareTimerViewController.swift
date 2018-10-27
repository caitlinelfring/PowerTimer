//
//  PrepareTimerViewController.swift
//  PowerTimer
//
//  Created by Caitlin on 9/22/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import PTTimer

class PrepareTimerViewController: UIViewController {
  var completion: (() -> ())?

  static let seconds = 5

  private let modalView = UIView()
  private let timer = PTTimer.Down(startSeconds: seconds)

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

    self.timerView.text = "\(self.timer.seconds())"
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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.timerView.font = TimerView.Constants.Active.font.withSize(self.view.minSafeAreaDimension())
  }
}


extension PrepareTimerViewController: PTTimerDelegate {
  func timerTimeDidChange(seconds: Int) {
    self.timerView.text = "\(seconds)"
  }

  func timerDidPause() {
    self.dismiss(animated: true, completion: self.completion)
  }
}
