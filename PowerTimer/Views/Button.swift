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
    self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.isUserInteractionEnabled = true
    self.imageView!.tintColor = .white
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 2

    self.translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let radius = self.bounds.size.width / 2
    self.layer.cornerRadius = radius
  }
}

class PlayPauseButton: ImageButton {
  enum buttonImage {
    case play
    case pause

    func image() -> UIImage {
      switch self {
      case .play:
        return UIImage(named: "play")!
      case .pause:
        return UIImage(named: "pause")!
      }
    }
  }
  var currentButtonImage: buttonImage = .play {
    didSet {
      self.setCurrentButtonImage()
    }
  }

  var isPlay: Bool {
    return self.currentButtonImage == .play
  }

  var isPause: Bool {
    return self.currentButtonImage == .pause
  }

  convenience init() {
    self.init(frame: .zero)
    self.setCurrentButtonImage()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding = self.bounds.height / 5
    if self.isPlay {
      self.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding-2)
    } else {
      self.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
  }

  private func setCurrentButtonImage() {
    self.setImage(self.currentButtonImage.image().withRenderingMode(.alwaysTemplate), for: .normal)
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
