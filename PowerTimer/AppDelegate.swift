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

    let mask: CALayer = {
      let mask = CALayer()
      mask.contents = UIImage(named: "clock_icon")!.cgImage
      mask.contentsGravity = kCAGravityResizeAspect
      mask.bounds = CGRect(origin: .zero, size: CGSize(width: self.window!.frame.size.width/4, height: self.window!.frame.size.height/4))
      mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      mask.position = CGPoint(x: self.window!.frame.size.width/2, y: self.window!.frame.size.height/2)
      return mask
    }()

    self.window!.backgroundColor = UIColor(red: 0.789, green: 1, blue: 0.837, alpha: 1) // trying to match lauch screen
    self.window!.rootViewController =  UINavigationController(rootViewController: TimerViewController())
    self.window!.rootViewController!.view.layer.mask = mask
    self.window!.makeKeyAndVisible()

    UIView.transition(with: self.window!, duration: 1, options: .transitionCrossDissolve, animations: {
      self.animate(mask: mask)
    }, completion: nil)

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
    keyFrameAnimation.keyTimes = [0, 0.3, 0.7]
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

