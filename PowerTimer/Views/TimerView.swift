//
//  TimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class TimerView: UIView {

  class Constants {
    static var font: UIFont {
      let bounds = UIScreen.main.bounds
      var fontSize = bounds.width * 0.25
      if bounds.width > bounds.height {
        fontSize = bounds.height * 0.25
      }
      return  UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
    }
    static let textColor: UIColor = .white
  }

  let label = UILabel()
  let textLabel = UILabel()

  var color: UIColor = Constants.textColor {
    didSet {
      self.label.textColor = self.color
      self.textLabel.textColor = self.color
    }
  }

  private var currentText = "00:00" {
    didSet {
      let attributedText = NSAttributedString(string: self.currentText, attributes: [NSAttributedStringKey.kern: 5])
      self.label.attributedText = attributedText
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.label.adjustsFontSizeToFitWidth = true
    self.label.textAlignment = .center
    self.addSubview(self.label)
    self.label.translatesAutoresizingMaskIntoConstraints = false
    self.label.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.setTime(seconds: 0)

    self.textLabel.textColor = .white
    self.textLabel.textAlignment = .center
    self.textLabel.font = UIFont.systemFont(ofSize: 20)
    self.textLabel.adjustsFontSizeToFitWidth = true
    self.addSubview(self.textLabel)
    self.textLabel.translatesAutoresizingMaskIntoConstraints = false
    self.textLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.textLabel.topAnchor.constraint(equalTo: self.label.bottomAnchor).isActive = true
    self.textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    self.label.font = Constants.font
    self.label.textColor = Constants.textColor
  }

  func setTime(seconds: Int) {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    self.currentText = String(format: "%02d:%02d", minutesValue, secondsValue)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func enlarge() {
    if label.font != Constants.font {
      self.animate(Constants.font, color: .white)
    }
  }
  func soften() {
    let newFont = Constants.font.withSize(Constants.font.pointSize - 20)
    if self.label.font != newFont {
      self.animate(newFont, color: .gray)
    }
  }

  func animate(_ font: UIFont, color: UIColor) {
    let duration: TimeInterval = 0.25

    let oldFont = self.label.font
    self.label.font = font
    let labelScale = oldFont!.pointSize / font.pointSize
    let oldTransform = self.label.transform
    self.label.transform = self.label.transform.scaledBy(x: labelScale, y: labelScale)

    self.setNeedsUpdateConstraints()
    self.superview?.setNeedsUpdateConstraints()
    UIView.animate(withDuration: duration) {
      self.label.textColor = color
      self.label.transform = oldTransform
      self.layoutIfNeeded()
      self.superview?.layoutIfNeeded()
    }
  }
}

extension UILabel {
  func animate(toFont font: UIFont, color: UIColor, withDuration duration: TimeInterval) {
    let oldFont = self.font
    self.font = font
    let labelScale = oldFont!.pointSize / font.pointSize
    let oldTransform = self.transform
    self.transform = self.transform.scaledBy(x: labelScale, y: labelScale)

    setNeedsUpdateConstraints()
    superview?.setNeedsUpdateConstraints()
    UIView.animate(withDuration: duration) {
      self.textColor = color
      self.transform = oldTransform
      self.layoutIfNeeded()
      self.superview?.layoutIfNeeded()
      self.superview?.superview?.layoutIfNeeded()
    }
  }
}
