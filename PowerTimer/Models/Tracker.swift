//
//  Tracker.swift
//  PowerTimer
//
//  Created by Caitlin on 9/22/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import Firebase

class Tracking {
  class func log(_ event: String, parameters: [String: Any]? = nil) {
    let evt = event.replacingOccurrences(of: ".", with: "_") // Firebase event name must contain only letters, numbers, or underscores
    print("event tracking: \(evt) with params: \(String(describing: parameters))")
    Analytics.logEvent(evt, parameters: parameters)
  }
}
