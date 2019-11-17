//
//  SettingCell.swift
//  PowerTimer
//
//  Created by Caitlin on 11/17/19.
//  Copyright © 2019 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class SettingsCell: UITableViewCell {
  private(set) var accessory = UIView()

  var isEnabled: Bool = true {
    didSet {
      self.accessory.isUserInteractionEnabled = isEnabled
    }
  }
  private let label = UILabel()
  private let container = UIView()

  var title: String? {
    set(value) {
      self.label.text = value
    }
    get {
      return self.label.text
    }
  }

  convenience init() {
    self.init(style: .default, reuseIdentifier: nil)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.container)
    self.container.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
        .inset(UIEdgeInsets(top: 5, left: 16, bottom: 10, right: 0))
        .priority(999)
    }
    self.container.addSubview(self.label)
    self.label.snp.makeConstraints({ (make) in
      make.edges.equalToSuperview()
    })
  }

  convenience init(accessory: UIView) {
    self.init(style: .default, reuseIdentifier: nil)

    self.accessory = accessory
    self.container.addSubview(self.accessory)
    self.accessory.snp.makeConstraints { (make) in
      make.left.bottom.equalToSuperview()
      make.top.equalTo(self.container.snp.centerY)
    }
    self.label.snp.remakeConstraints({ (make) in
      make.right.top.left.equalToSuperview()
      make.bottom.equalTo(self.container.snp.centerY)
    })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
