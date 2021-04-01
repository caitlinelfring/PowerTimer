//
//  ClockView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class ClockView: UIView {
  let clock = UILabel()
  private var clockUpdateTimer: Timer!

  private var dateFormatter: DateFormatter = {
    let df = DateFormatter()
    // https://stackoverflow.com/questions/1929958/how-can-i-determine-if-iphone-is-set-for-12-hour-or-24-hour-time-display
    let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
    let hasAMPM = formatString.contains("a")
    if hasAMPM {
      df.dateFormat = "h:mm a"
    } else {
      df.dateFormat = "HH:mm"
    }
    return df
  }()

  var currentTime: String {
    #if DEBUG
    if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
      return "9:14 AM"
    }
    #endif
    return self.dateFormatter.string(from: Date())
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.clockUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
      self.update()
    })
    self.clockUpdateTimer.tolerance = 30

    let font = UIFont(name: "Helvetica-Light", size: min(100, Settings.minScreenDimension * 0.125))
    self.clock.font = font
    self.clock.textColor = .darkGray
    self.clock.textAlignment = .center
    self.addSubview(self.clock)
    self.clock.translatesAutoresizingMaskIntoConstraints = false
    self.clock.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    self.clock.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.clock.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.clock.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

    self.update()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // TODO: This should update if the clock 12/24 hr setting changes, but how likely is that to really happen?
  func update() {
    let chars = self.currentTime.split(separator: " ")
    let time = String(chars[0])
    let attributedString = NSMutableAttributedString(string: time, attributes: [NSAttributedString.Key.font : self.clock.font])

    if chars.count > 1 {
      let ampm = String(chars[1].lowercased())
      attributedString.append(NSMutableAttributedString(string: " " + ampm, attributes: [NSAttributedString.Key.font : self.clock.font.withSize(self.clock.font.pointSize * 0.5)]))
    }
    self.clock.attributedText = attributedString
  }
}
