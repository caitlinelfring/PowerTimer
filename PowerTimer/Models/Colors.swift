//
//  Colors.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class Colors {
  static let green = hexToRGB(hexString: "#2A7100")
  static let red = hexToRGB(hexString: "#801B00")
  static let orange = hexToRGB(hexString: "#C66304")
  static var yellow: UIColor { return forCurrentTheme(dark: .yellow, light: hexToRGB(hex: 0xFFD300)) }

  static var navigationBarTintColor: UIColor { return forCurrentTheme(dark: .gray, light: .black) }
  static var backgroundColor: UIColor { return forCurrentTheme(dark: .black, light: .white) }
  static var timerInactive: UIColor { return forCurrentTheme(dark: .gray, light: .lightGray) }
  static var timerActive: UIColor { return forCurrentTheme(dark: .white, light: .black) }
  static var buttonColor: UIColor { return forCurrentTheme(dark: .white, light: .black) }

  static let logoForeground: UIColor = hexToRGB(hex: 0xFF66FF)
  static let logoShadow: UIColor = hexToRGB(hex: 0x5A40FF)

  class func forCurrentTheme(dark: UIColor, light: UIColor) -> UIColor {
    return Settings.currentTheme == .dark ? dark : light
  }

  class func hexToRGB(hex: Int) -> UIColor {
    return UIColor(red: CGFloat((hex >> 16) & 0xff) / 255,
                   green: CGFloat((hex >> 8) & 0xff) / 255,
                   blue: CGFloat(hex & 0xff) / 255, alpha: 1.0)
  }

  class func hexToRGB(hexString: String) -> UIColor {
    let hexWithoutPrefix = hexString.replacingOccurrences(of: "#", with: "")
    let hexInt = Int(hexWithoutPrefix, radix: 16)!
    return hexToRGB(hex: hexInt)
  }
}
