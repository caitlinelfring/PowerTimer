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
    print("event tracking: \(event) with params: \(String(describing: parameters))")
    Analytics.logEvent(event, parameters: parameters)
  }
}
