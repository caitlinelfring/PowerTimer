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
  private let close = CloseButton()

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
    self.view.addSubview(self.close)
    self.close.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
      make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(10)
    }
    self.close.addTarget(self, action: #selector(self.closeTimer), for: .touchUpInside)

    self.timer.delegate = self
    self.timer.start()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.timerView.font = TimerView.Constants.Active.font.withSize(self.view.minSafeAreaDimension())
    self.close.iconSize = self.view.minSafeAreaDimension() / 20
  }

  @objc func closeTimer() {
    self.timer.pause()
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

private class CloseButton: UIButton {

  var iconSize: CGFloat = 10
  var lineWidth: CGFloat = 1
  var lineColor: UIColor = UIColor.white.withAlphaComponent(0.54)

  convenience init(iconSize: CGFloat, lineWidth: CGFloat) {
    self.init()
    self.iconSize = iconSize
    self.lineWidth = lineWidth
  }

  override func draw(_ rect: CGRect) {
    let path = UIBezierPath()

    path.lineWidth = lineWidth
    path.lineCapStyle = .round

    let iconFrame = CGRect(
      x: (rect.width - iconSize) / 2.0,
      y: (rect.height - iconSize) / 2.0,
      width: iconSize,
      height: iconSize
    )

    path.move(to: iconFrame.origin)
    path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
    path.move(to: CGPoint(x: iconFrame.maxX, y: iconFrame.minY))
    path.addLine(to: CGPoint(x: iconFrame.minX, y: iconFrame.maxY))

    lineColor.setStroke()

    path.stroke()
  }
}
