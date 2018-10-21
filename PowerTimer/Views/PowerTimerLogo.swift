//
//  PowerTimerLogo.swift
//  PowerTimer
//
//  Created by Caitlin on 9/22/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class PowerTimerLogo: UILabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  convenience init(kerning: Float = 0, font: UIFont) {
    self.init(frame: .zero)

    if kerning > 0 {
      self.kerning = kerning
    }
    self.font = font
    self.text = "PowerTimer"
    self.textColor = Colors.logoForeground
    self.shadowColor = Colors.logoShadow
    self.shadowOffset = CGSize(width: 3, height: 3)
    self.sizeToFit()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

//https://stackoverflow.com/questions/7370013/how-to-set-kerning-in-iphone-uilabel#34757069
extension UILabel {

  @IBInspectable var kerning: Float {
    get {
      var range = NSMakeRange(0, (self.text?.count ?? 0))
      guard let kern = self.attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: &range),
        let value = kern as? NSNumber
        else {
          return 0
      }
      return value.floatValue
    }
    set {
      var attText: NSMutableAttributedString

      if let attributedText = self.attributedText {
        attText = NSMutableAttributedString(attributedString: attributedText)
      } else if let text = self.text {
        attText = NSMutableAttributedString(string: text)
      } else {
        attText = NSMutableAttributedString(string: "")
      }

      let range = NSMakeRange(0, attText.length)
      attText.addAttribute(NSAttributedString.Key.kern, value: NSNumber(value: newValue), range: range)
      self.attributedText = attText
    }
  }
}
