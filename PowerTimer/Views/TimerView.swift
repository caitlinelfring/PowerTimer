//
//  TimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TimerView: UIView {
  enum State {
    case active
    case paused
    case inactive

    func color() -> UIColor {
      switch self {
      case .active:
        return Constants.Active.textColor
      case .inactive:
        return Constants.Inactive.textColor
      case .paused:
        return Colors.yellow
      }
    }
  }

  class Constants {
    class Active {
      static var font: UIFont {
        return  UIFont(name: "HelveticaNeue-Medium", size: Settings.minScreenDimension * 0.25)!
      }
      static var textColor: UIColor { return Colors.timerActive }
    }

    class Inactive {
      static var font: UIFont {
        return Constants.Active.font.withSize(Constants.Active.font.pointSize - (Settings.minScreenDimension * 0.06))
      }
      static var textColor: UIColor { return Colors.timerInactive }
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

  var state: State = .active {
    didSet {
      self.color = self.state.color()
      switch state {
      case .active:
        self.enlarge(animate: true)
      case .inactive:
        self.soften(animate: true)
      case .paused:
        self.enlarge(animate: true)
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.label.adjustsFontSizeToFitWidth = true
    self.label.textAlignment = .center
    self.addSubview(self.label)
    self.label.snp.makeConstraints { (make) in
      make.top.width.centerX.equalToSuperview()
    }
    self.setTime(seconds: 0)

    self.textLabel.textAlignment = .center
    self.textLabel.font = UIFont.systemFont(ofSize: min(80, Settings.minScreenDimension * 0.06))
    self.textLabel.adjustsFontSizeToFitWidth = true
    self.addSubview(self.textLabel)
    self.textLabel.snp.makeConstraints { (make) in
      make.width.centerX.bottom.equalToSuperview()
      make.top.equalTo(self.label.snp.bottom)
    }

    self.label.font = Constants.Active.font
    self.label.textColor = self.color
    self.textLabel.textColor = self.color
  }

  func setTime(seconds: Int) {
    self.currentText = TimerView.formatTime(seconds: seconds)
  }

  class func formatTime(seconds: Int) -> String {
    let minutesValue =  seconds % (1000 * 60) / 60
    let secondsValue = seconds % 60
    return String(format: "%02d:%02d", minutesValue, secondsValue)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func enlarge(animate: Bool = true) {
    if self.label.font != Constants.Active.font {
      self.animateTo(font: Constants.Active.font, animate: animate)
    }
  }

  private func soften(animate: Bool = true) {
    if self.label.font != Constants.Inactive.font {
      self.animateTo(font: Constants.Inactive.font, animate: animate)
    }
  }

  private func animateTo(font: UIFont, animate: Bool = true) {
    let duration: TimeInterval = 0.25
    let oldFont = self.label.font
    self.label.font = font
    let labelScale = oldFont!.pointSize / font.pointSize

    self.label.transform = self.label.transform.scaledBy(x: labelScale, y: labelScale)
    self.label.setNeedsUpdateConstraints()
    let animations = {
      self.label.transform = .identity
      self.layoutIfNeeded()
      // So all the views that are around this view animate too
      self.superview?.layoutIfNeeded()
      self.superview?.superview?.layoutIfNeeded()
    }

    if animate {
      UIView.animate(withDuration: duration,
                     delay: 0,
                     options: UIViewAnimationOptions.allowUserInteraction,
                     animations: animations,
                     completion: nil)
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
