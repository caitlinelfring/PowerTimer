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
    df.dateFormat = "h:mm a"
    return df
  }()

  var currentTime: String {
    return self.dateFormatter.string(from: Date())
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.clockUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
      self.update()
    })
    self.clockUpdateTimer.tolerance = 30

    let font = UIFont(name: "Helvetica Light", size: 55)
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

  func update() {
    let chars = self.currentTime.split(separator: " ")
    let time = String(chars[0])
    let ampm = String(chars[1].lowercased())

    let attributedString = NSMutableAttributedString(string: time, attributes: [NSAttributedStringKey.font : self.clock.font])
    attributedString.append(NSMutableAttributedString(string: " " + ampm, attributes: [NSAttributedStringKey.font : self.clock.font.withSize(20)]))

    self.clock.attributedText = attributedString
  }
}
