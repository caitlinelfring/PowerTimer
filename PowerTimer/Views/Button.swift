//
//  Button.swift
//  PowerTimer
//
//  Created by Caitlin on 5/16/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class ImageButton: UIButton {
  convenience init(image: UIImage) {
    self.init(frame: .zero)
    self.isUserInteractionEnabled = true
    self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
    self.imageView!.tintColor = .white
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 2

    self.translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let radius = self.bounds.size.width / 2
    self.layer.cornerRadius = radius
  }
}

class PlayButton: ImageButton {
  convenience init() {
    self.init(image: UIImage(named: "play")!)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding = self.bounds.height / 5
    self.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding-2)
  }
}

class PauseButton: ImageButton {
  convenience init() {
    self.init(image: UIImage(named: "pause")!)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding = self.bounds.height / 5
    self.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
  }
}

class RefreshButton: ImageButton {
  convenience init() {
    self.init(image: UIImage(named: "refresh")!)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding = self.bounds.height / 5
    self.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding-2)
  }
}
