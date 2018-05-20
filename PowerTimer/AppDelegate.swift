//
//  AppDelegate.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import UIKit
import Fingertips

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    #if DEBUG
//      print("Using Fingertips window")
//      let fingertips = MBFingerTipWindow(frame: UIScreen.main.bounds)
//      fingertips.alwaysShowTouches = true
//      fingertips.fadeDuration = 0.7
//      self.window = fingertips
    #endif

    self.window!.backgroundColor = UIColor(red: 0.789, green: 1, blue: 0.837, alpha: 1) // trying to match lauch screen
    self.window!.makeKeyAndVisible()
    let navigationController = UINavigationController(rootViewController: TimerViewController())
    self.window!.rootViewController = navigationController

    // Animation based on https://github.com/okmr-d/App-Launching-like-Twitter
    // logo mask
    let mask: CALayer = {
      let mask = CALayer()
      mask.contents = UIImage(named: "clock_icon.png")!.cgImage
      mask.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
      mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      mask.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)
      return mask
    }()
    navigationController.view.layer.mask = mask


    // logo mask background view
    let maskBgView = UIView(frame: navigationController.view.frame)
    maskBgView.backgroundColor = UIColor.black
    navigationController.view.addSubview(maskBgView)
    navigationController.view.bringSubview(toFront: maskBgView)

    // logo mask animation
    let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
    transformAnimation.delegate = self
    transformAnimation.duration = 1
    transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
    let initalBounds = NSValue(cgRect: navigationController.view.layer.mask!.bounds)
    let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 50, height: 50))
    let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 8000, height: 8000))
    transformAnimation.values = [initalBounds, secondBounds, finalBounds]
    transformAnimation.keyTimes = [0, 0.3, 1]
    transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
    transformAnimation.isRemovedOnCompletion = false
    transformAnimation.fillMode = kCAFillModeForwards
    navigationController.view.layer.mask!.add(transformAnimation, forKey: "maskAnimation")

    // logo mask background view animation
    UIView.animate(withDuration: 0.1, delay: 1.35, options: UIViewAnimationOptions.curveEaseIn, animations: {
      maskBgView.alpha = 0.0
    }, completion: { finished in maskBgView.removeFromSuperview() })

    print(Date())

    TipManager.setup()
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  // Based on https://github.com/rounak/TwitterBirdAnimation
  func animate(mask: CALayer) {
    let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
    keyFrameAnimation.delegate = self
    keyFrameAnimation.duration = 1
    keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
    let initalBounds = NSValue(cgRect: mask.bounds)
    let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: mask.bounds.width - 10, height: mask.bounds.height - 10))
    let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: mask.bounds.width * 200, height: mask.bounds.height * 200))
    keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
    keyFrameAnimation.keyTimes = [0, 0.3, 1]
    keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
    mask.add(keyFrameAnimation, forKey: "bounds")
  }

}
extension AppDelegate: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    // FIXME: on my iPhone 6, the mask is shown again for a split second after the animation completes
    self.window!.rootViewController!.view.layer.mask = nil
  }
}

