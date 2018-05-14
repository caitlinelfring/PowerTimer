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
