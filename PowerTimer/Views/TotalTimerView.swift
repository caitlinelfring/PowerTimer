//
//  TotalTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TimerActions: UIView {
  var onTimerStart: (() -> ())?
  var onTimerPaused: (() -> ())?
  var onTimerReset: (() -> ())?
}

class TotalTimerView: TimerActions {
  let timer = CountUpTimer()
  let timerView = TimerView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self
    self.addSubview(self.timerView)
    self.timerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    self.timerView.enlarge()
    self.timerView.setTime(seconds: 0)
    self.timerView.textLabel.text = "Total Time"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TotalTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, String(describing: type(of: self)), seconds)
    self.timerView.setTime(seconds: seconds)
  }

  func onPaused() {
    print(#function)
    self.timerView.color = .yellow
    self.onTimerPaused?()
  }

  func onStart() {
    print(#function)
    self.timerView.color = .white
    self.onTimerStart?()
  }

  func onReset() {
    print(#function)
    self.timerView.color = .white
    self.timerView.setTime(seconds: 0)
    self.timerView.enlarge()
    self.onTimerReset?()
  }
}

