//
//  RestTimeStepper.swift
//  PowerTimer
//
//  Created by Caitlin on 5/18/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import ValueStepper

class RestTimerStepper: ValueStepper {

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.minimumValue = 1
    self.maximumValue = 20
    self.stepValue = 1
    self.autorepeat = false
    self.backgroundLabelColor = .clear
    self.backgroundColor = .clear
    self.backgroundButtonColor = .clear
    self.highlightedBackgroundColor = .clear
    self.updateColors()
  }

  func updateColors() {
    self.tintColor = TimerView.Constants.Inactive.textColor
    self.labelTextColor = TimerView.Constants.Inactive.textColor
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // Only way I could figure out how to redraw when the layout changes
  // (like when this is in a UITableViewCell and the height changes)
  override func layoutSubviews() {
    super.layoutSubviews()
    self.draw(self.bounds)
  }
}

class SettingsCountDownTimerStepper: RestTimerStepper {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.maximumValue = 90
    self.enableManualEditing = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
