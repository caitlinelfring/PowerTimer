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
    if let sound = Settings.Sound.soundAlertID, Settings.Sound.playSoundAlert {
      sound.play()
    }
  }

  class func play(id: Sounds.ID) {
    AudioServicesPlayAlertSound(SystemSoundID(id.rawValue))
  }

  enum ID: Int {
    case anticipate = 1320
    case bloom = 1321
    case calypso = 1322
    case choochoo = 1323
    case descent = 1324
    case fanfare = 1325
    case ladder = 1326
    case minuet = 1327
    case newsFlash = 1328
    case noir = 1329
    case sherwoodForest = 1330
    case spell = 1331
    case suspense = 1332
    case telegraph = 1333
    case tiptoes = 1334
    case typewriters = 1335
    case update = 1336

    func play() {
      Sounds.play(id: self)
    }

    var displayName: String {
      switch self {
      case .anticipate: return "Anticipate"
      case .bloom: return "Bloom"
      case .calypso: return "Calypso"
      case .choochoo: return "Choo Choo"
      case .descent: return "Descent"
      case .fanfare: return "Fanfare"
      case .ladder: return "Ladder"
      case .minuet: return "Minuet"
      case .newsFlash: return "News Flash"
      case .noir: return "Noir"
      case .sherwoodForest: return "Sherwood Forest"
      case .spell: return "Spell"
      case .suspense: return "Suspense"
      case .telegraph: return "Telegraph"
      case .tiptoes: return "Tip Toes"
      case .typewriters: return "Typewriters"
      case .update: return "Update"
      }
    }
    static let allValues: [Sounds.ID] = [
      .anticipate,
      .bloom,
      .calypso,
      .choochoo,
      .descent,
      .fanfare,
      .ladder,
      .minuet,
      .newsFlash,
      .noir,
      .sherwoodForest,
      .spell,
      .suspense,
      .telegraph,
      .tiptoes,
      .typewriters,
      .update,
    ]
  }
}

class SoundsTableViewController: UITableViewController {
  let cellID = "soundCell"

  convenience init() {
    self.init(style: .plain)
  }
  override init(style: UITableViewStyle) {
    super.init(style: style)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(self.close))

    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.tableFooterView = UIView()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellID)

    self.navigationItem.title = "ALERT SETTINGS"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let currentSound = Settings.Sound.soundAlertID {
      let index = Sounds.ID.allValues.index(of: currentSound)!
      self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .middle)
    }
  }

  @objc func close() {
    self.dismiss(animated: true, completion: nil)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Sounds.ID.allValues.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)

    let sound = Sounds.ID.allValues[indexPath.row]
    cell.textLabel?.text = sound.displayName
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sound = Sounds.ID.allValues[indexPath.row]
    Settings.Sound.soundAlertID = sound
    sound.play()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
