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
  fileprivate class Constants {
    static let highlighted = Colors.forCurrentTheme(dark: .lightGray, light: .darkGray)
    static let disabled = UIColor.darkGray
  }
  convenience init(image: UIImage) {
    self.init(frame: .zero)
    self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
  }

  var color: UIColor = Colors.timerActive {
    didSet {
      let color = self.isEnabled ? self.color : Constants.disabled
      self.imageView!.tintColor = color
      self.layer.borderColor = color.cgColor
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.isUserInteractionEnabled = true
    self.adjustsImageWhenDisabled = false
    self.adjustsImageWhenHighlighted = false
    self.imageView!.tintColor = self.color
    self.layer.borderColor = self.color.cgColor
    self.layer.borderWidth = 2

    self.translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isHighlighted: Bool {
    didSet {
      self.color = self.isHighlighted ? Constants.highlighted : Colors.buttonColor
    }
  }

  override var isEnabled: Bool {
    didSet {
      self.color = self.isEnabled ? Colors.buttonColor : Constants.disabled
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let radius = self.bounds.size.width / 2
    self.layer.cornerRadius = radius

    if self.state == .disabled {
      self.isEnabled = false
    }
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

class ResetButton: ImageButton {
  convenience init() {
    self.init(image: UIImage(named: "refresh")!)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding = self.bounds.height / 5
    self.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding-2)
  }
}
