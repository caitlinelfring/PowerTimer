//
//  RestTimerView.swift
//  PowerTimer
//
//  Created by Caitlin on 5/14/18.
//  Copyright © 2018 JEddie, LLC. All rights reserved.
//

import Foundation
import UIKit

class RestTimerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

  let timer = CountUpTimer()
  var startTapGestureRecognizer: UITapGestureRecognizer!
  var setTapGestureRecognizer: UITapGestureRecognizer!
  var restTime: Int = 0

  var showRestTimerInput: ((UIAlertController) -> Void)?

  private let timerLabel = TimerLabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.timer.delegate = self
    self.timerLabel.textAlignment = .center
    self.addSubview(self.timerLabel)
    self.timerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.timerLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    self.timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    self.timerLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    self.isUserInteractionEnabled = true

    let timerTextLabel = UILabel()
    timerTextLabel.text = "Rest Time"
    timerTextLabel.textColor = .white
    timerTextLabel.textAlignment = .center
    timerTextLabel.font = UIFont.systemFont(ofSize: 16)
    timerTextLabel.adjustsFontSizeToFitWidth = true
    self.addSubview(timerTextLabel)
    timerTextLabel.translatesAutoresizingMaskIntoConstraints = false
    timerTextLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    timerTextLabel.topAnchor.constraint(equalTo: self.timerLabel.bottomAnchor).isActive = true
    timerTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    self.startTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.startTap))
    self.startTapGestureRecognizer.numberOfTapsRequired = 1
    self.addGestureRecognizer(self.startTapGestureRecognizer)

    self.setTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.setTap))
    self.setTapGestureRecognizer.numberOfTapsRequired = 2
    self.addGestureRecognizer(self.setTapGestureRecognizer)
  }
  var pickerSet: [String] = {
    var set = [String]()
    for i in 1...10 {
      set.append(String(i))
    }
    return set
  }()

  @objc private func setTap(sender: UITapGestureRecognizer) {
    print(#function, sender)
    if self.timer.isActive {
      self.timer.pause()
      return
    }

    let message = "\n\n\n\n\n\n\n"
    let alert = UIAlertController(title: "Set Rest Time Minutes", message: message, preferredStyle: .alert)
    alert.isModalInPopover = true

    //Create a frame (placeholder/wrapper) for the picker and then create the picker
    let pickerFrame: CGRect = CGRect(x: 35, y: 52, width: 200, height: 140) // CGRectMake(left, top, width, height) - left and top are like margins
    let picker: UIPickerView = UIPickerView(frame: pickerFrame)

    //set the pickers datasource and delegate
    picker.delegate = self
    picker.dataSource = self

    //Add the picker to the alert controller
    alert.view.addSubview(picker)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancelAction)

    let okAction = UIAlertAction(title: "Start", style: .default, handler: { _ in
      self.restTime = Int(self.pickerSet[picker.selectedRow(inComponent: 0)])! * 60
      self.timer.start()
    })
    alert.addAction(okAction)

    self.showRestTimerInput?(alert)
  }

  @objc private func startTap(sender: UITapGestureRecognizer) {
    if self.restTime == 0 {
      self.setTap(sender: sender)
      return
    }
    if self.timer.isActive {
      self.timer.reset()
    } else {
      self.timer.start()
    }
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.pickerSet.count
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return self.pickerSet[row]
  }
}

extension RestTimerView: TimerDelegate {
  func onTimeChanged(seconds: Int) {
    print(#function, seconds)
    self.timerLabel.setTime(seconds: seconds)
    self.timerLabel.textColor = seconds > self.restTime ? Colors.red : .white
  }

  func onPaused() {
    print(#function)
  }

  func onStart() {
    print(#function)
  }

  func onReset() {
    print(#function)
    self.timerLabel.setTime(seconds: 0)
  }
}

