//
//  Sounds.swift
//  PowerTimer
//
//  Created by Caitlin on 5/24/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Sounds {

  class func playIfConfigured() {
    if Settings.Sound.playSoundAlert {
      guard let url = Bundle.main.url(forResource: "airhorn", withExtension: "mp3", subdirectory: "sounds") else {
        fatalError("cannot get url for airhorn")
      }
      var customSoundId: SystemSoundID = 0
      AudioServicesCreateSystemSoundID(url as CFURL, &customSoundId)
      //let systemSoundId: SystemSoundID = 1016  // to play apple's built in sound, no need for upper 3 lines

      AudioServicesAddSystemSoundCompletion(customSoundId, nil, nil, { (customSoundId, _) -> Void in
        AudioServicesDisposeSystemSoundID(customSoundId)
      }, nil)

      AudioServicesPlaySystemSound(customSoundId)
    }
  }
}
