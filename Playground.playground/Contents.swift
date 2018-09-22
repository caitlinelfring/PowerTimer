//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Foundation

enum Model {
  case iPhoneSE
  case iPhone7
  case iPhone7Plus
  case iPhoneX
}

class MainViewController: ViewController {
  private var mainVC: UINavigationController!
  let label = UILabel()
  let maskBgView = UIView(frame: CGRect(origin: .zero, size: Model.iPhoneSE.rawValue))
  var labelCenterYStart: NSLayoutConstraint!
  var labelCenterYEnd: NSLayoutConstraint!

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    print(Date())

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.mainVC = UINavigationController(rootViewController: UIViewController())

    let attributes: [NSAttributedStringKey: Any] = [
      NSAttributedStringKey.foregroundColor: UIColor(red: 1, green: 0.4, blue: 0.93, alpha: 1),
      NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 55)!,
      ]
    label.allowsDefaultTighteningForTruncation = true
    label.shadowColor = UIColor(red: 0.35, green: 0.25, blue: 1, alpha: 1)
    label.shadowOffset = CGSize(width: 4, height: 4)
    label.attributedText = NSAttributedString(string: "PowerTimer", attributes: attributes)
    label.sizeToFit()
    label.layoutIfNeeded()

    maskBgView.backgroundColor = .black

    maskBgView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.widthAnchor.constraint(equalToConstant: 306).isActive = true
    self.labelCenterYStart = label.centerYAnchor.constraint(equalTo: maskBgView.centerYAnchor)
    labelCenterYStart.isActive = true
    label.centerXAnchor.constraint(equalTo: maskBgView.centerXAnchor).isActive = true
    self.view.addSubview(maskBgView)
    self.view.bringSubview(toFront: maskBgView)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.startLoadingAnimation()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func startLoadingAnimation() {
//    let fontSize = min(Settings.minScreenDimension * 0.06, self.mainVC.navigationBar.frame.size.height)
//    self.labelCenterYEnd = label.centerYAnchor.constraint(equalTo: self.mainVC.navigationBar.centerYAnchor)
//    labelCenterYEnd.isActive = false
    UIView.animate(withDuration: 0.25, delay: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
      self.label.transform = self.label.transform.scaledBy(x: 0.9, y: 0.9)

      self.label.center.y -= self.view.bounds.height - 100

//      self.labelCenterYEnd.isActive = true
      self.label.layoutIfNeeded()
    }, completion: { finished in
      UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
        self.maskBgView.alpha = 0.0
//        self.label.transform = self.label.transform.scaledBy(x: 100, y: 100)
        self.label.layoutIfNeeded()
      }, completion: { finished in
        self.maskBgView.removeFromSuperview()
      })
    })
  }

//  private func animateTo(label: UILabel, font: UIFont, animate: Bool = true) {
//    let duration: TimeInterval = 0.25
//    let oldFont = label.font
//    label.font = font
//    let labelScale = oldFont!.pointSize / font.pointSize
//
//    label.transform = label.transform.scaledBy(x: labelScale, y: labelScale)
//    label.setNeedsUpdateConstraints()
//    let animations = {
//      label.transform = .identity
//      label.center = self.mainVC.navigationBar.center
//
//      self.view.layoutIfNeeded()
//      // So all the views that are around this view animate too
//      //      self.superview?.layoutIfNeeded()
//      //      self.superview?.superview?.layoutIfNeeded()
//      //      self.timerVC.overrideStatusBar = nil
//      //      self.timerVC.setNeedsStatusBarAppearanceUpdate()
//      //      maskBgView.removeFromSuperview()
//    }
//
//    if animate {
//      UIView.animate(withDuration: duration,
//                     delay: 0,
//                     options: UIViewAnimationOptions.allowUserInteraction,
//                     animations: animations,
//                     completion: nil)
//    } else {
//      animations()
//    }
//  }
}

class Settings {
  static var minScreenDimension: CGFloat {
    let bounds = UIScreen.main.bounds
    var smallerBounds = bounds.width
    if bounds.width > bounds.height {
      smallerBounds = bounds.height
    }
    return smallerBounds
  }
}


// --------------- Boilerplate ---------------
// You shouldn't need to touch any of this
// https://developer.apple.com/library/content/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Displays/Displays.html

extension Model {
  var rawValue: CGSize {
    switch self {
    case .iPhoneSE: return CGSize(width: 320, height: 568)
    case .iPhone7: return CGSize(width: 375, height: 667)
    case .iPhone7Plus: return CGSize(width: 414, height: 736)
    case .iPhoneX: return CGSize(width: 375, height: 812)
    }
  }
}

class ViewController: UIViewController{}

extension ViewController {
  public convenience init(model size: Model) {
    self.init(nibName: nil, bundle: nil)
    let frame = CGRect(origin: .zero, size: size.rawValue)
    self.view.frame = frame
    self.preferredContentSize = size.rawValue
    let window = UIWindow(frame: frame)
    window.rootViewController = self
  }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MainViewController(model: .iPhoneSE)
