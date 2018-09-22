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
  private let startButton = UIButton(type: .system)

  convenience init(completion: (() -> ())?) {
    self.init()
    self.completion = completion
    self.modalPresentationStyle = .overCurrentContext
  }
  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .clear

    self.modalView.backgroundColor = Colors.backgroundColor
    self.modalView.layer.borderWidth = 2
    self.modalView.layer.borderColor = UIColor.gray.cgColor
    self.modalView.layer.cornerRadius = 5
    self.view.addSubview(self.modalView)
    // TODO: Make sure this isn't too big on iPad
    self.modalView.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.width.equalToSuperview().dividedBy(1.5)
      make.height.equalToSuperview().dividedBy(4)
    }

    let offset: CGFloat = -15

    let color: UIColor = self.view.tintColor
    self.startButton.setTitle("START NOW", for: .normal)
    self.startButton.setTitleColor(color, for: .normal)
    self.startButton.addTarget(self, action: #selector(self.startButtonTapped), for: .touchUpInside)
    self.startButton.layer.borderColor = color.cgColor
    self.startButton.layer.borderWidth = 1.5
    self.startButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    self.modalView.addSubview(self.startButton)
    self.startButton.snp.makeConstraints { (make) in
      make.bottom.equalToSuperview().offset(offset)
      make.centerX.equalToSuperview()
    }

    self.timerView.text = "\(self.timer.currentSeconds)"
    self.timerView.font = TimerView.Constants.Active.font
    self.timerView.textColor = .green
    self.timerView.textAlignment = .center
    self.modalView.addSubview(self.timerView)
    self.timerView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(offset)
    }

    self.timer.delegate = self
    self.timer.start()
  }

  @objc func startButtonTapped(sender: UIButton) {
    self.done()
  }

  func done() {
    self.dismiss(animated: true, completion: self.completion)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.startButton.layer.cornerRadius = self.startButton.frame.height / 2

  }
}


extension PrepareTimerViewController: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    self.timerView.text = "\(seconds)"
  }

  func onReset() {}
  func onStart() {}
  func onPaused() {
    self.done()
  }
}
