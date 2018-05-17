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
    class Active {
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

    class Inactive {
      static var font: UIFont {
        return Constants.Active.font.withSize(Constants.Active.font.pointSize - 20)
      }

      static let textColor: UIColor = .gray
    }
  }

  let label = UILabel()
  let textLabel = UILabel()

  var color: UIColor = Constants.Active.textColor {
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
    self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    self.label.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
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

    self.label.font = Constants.Active.font
    self.label.textColor = self.color
    self.textLabel.textColor = self.color
  }

  func setTime(seconds: Int) {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    self.currentText = String(format: "%02d:%02d", minutesValue, secondsValue)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func enlarge(animate: Bool = true) {
    if label.font != Constants.Active.font {
      self.animateTo(font: Constants.Active.font, color: Constants.Active.textColor, animate: animate)
    }
  }
  func soften(animate: Bool = true) {
    if self.label.font != Constants.Inactive.font {
      self.animateTo(font: Constants.Inactive.font, color: Constants.Inactive.textColor, animate: animate)
    }
  }

  func animateTo(font: UIFont, color: UIColor, animate: Bool = true) {
    let duration: TimeInterval = 0.5
    let oldFont = self.label.font
    self.label.font = font
    let labelScale = oldFont!.pointSize / font.pointSize

    self.label.transform = self.label.transform.scaledBy(x: labelScale, y: labelScale)
    self.label.setNeedsUpdateConstraints()
    let animations = {
      self.label.transform = .identity
      self.color = color
      self.layoutIfNeeded()
      // So all the views that are around this view animate too
      self.superview?.layoutIfNeeded()
      self.superview?.superview?.layoutIfNeeded()
    }

    if animate {
      UIView.animate(withDuration: duration, animations: animations)
    } else {
      animations()
    }
  }
}


extension UIView {
  enum ShakeDirection {
    case horizontal
    case vertical
    case rotate
  }
  func shake(withDirection direction: ShakeDirection = .horizontal) {
    var shakeAnimation: CAKeyframeAnimation
    switch direction {
    case .horizontal:
      // https://gist.github.com/mourad-brahim/cf0bfe9bec5f33a6ea66
      shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
      shakeAnimation.values = [-5.0, 5.0, -5.0, 5.0, -2.5, 2.5, -1.25, 1.25, 0.0 ]
    case .vertical:
      shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
      shakeAnimation.duration = 0.6
    case .rotate:
      shakeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      shakeAnimation.values = [0.5, -0.5, 0.5, -0.5, 0.25, -0.25, 0.125, -0.125, 0.0 ]
    }
    shakeAnimation.duration = 0.6
    self.layer.add(shakeAnimation, forKey: "shake")
  }
}
