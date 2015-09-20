//
//  AltEditTimerViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/11/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class AltEditTimerViewController: UIViewController {
    
    // buttons
    @IBOutlet var timeKeys: [PawButton]!
    @IBOutlet weak var timeKeyContainer: UIView!
    @IBOutlet weak var deleteKey: KeyPadControlButton!
    @IBOutlet weak var keyPadContainer: UIView!
    weak var timerActionView: TimerActionView!
    
    // labels
    @IBOutlet var tertiaryColorLabels: [UILabel]!
    @IBOutlet var primaryColorLabels: [UILabel]!
    @IBOutlet var secondaryColorLabels: [UILabel]!
    @IBOutlet var secondsLabel: UILabel!
    @IBOutlet var minutesLabel: UILabel!
    @IBOutlet var hoursLabel: UILabel!
    
    // constraints
    @IBOutlet var topLayoutConstraint: NSLayoutConstraint!
    
    // data
    var timerValue: [Int] = [Int]() {
        didSet {
            if (timerValue.count == 0) {
                self.deleteKey.layer.opacity = 0
                self.timerActionView.showCancelButtonOnly()
            } else {
                self.deleteKey.layer.opacity = 1
                self.timerActionView.showStartAndCancelButtons()
            }
            
            self.view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.125, animations: { [unowned self] () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.primaryColorLabels.map { (label: UILabel) -> UILabel in
            label.textColor = UIColor.primaryTextColor()
            return label
        }
        
        self.secondaryColorLabels.map { (label: UILabel) -> UILabel in
            label.textColor = UIColor.secondaryTextColor()
            return label
        }
        
        self.tertiaryColorLabels.map { (label: UILabel) -> UILabel in
            label.textColor = UIColor.tertiaryTextColor()
            return label
        }
        
        if (UIScreen.mainScreen().bounds.size.width <= 320) {
            self.topLayoutConstraint.constant = 8
            var translationTransform = CGAffineTransformMakeTranslation(0, 60)
            self.timeKeyContainer.transform = CGAffineTransformScale(translationTransform, 0.8, 0.8)
        }
        
        self.deleteKey.layer.opacity = 0
        self.addTimerActionView()
        self.timerActionView.cancelButton.addTarget(self, action: "onCancelKeyTap", forControlEvents: .TouchUpInside)
        self.timerActionView.startButton.addTarget(self, action: "onStartKeyTap", forControlEvents: .TouchUpInside)
    }
    
    func parseTime() -> [String: Int] {
        var inputs = timerValue
        
        if (inputs.count < 6) {
            for i in 1...(6 - inputs.count) {
                inputs.insert(Int(0), atIndex: 0)
            }
        }
        
        return ["seconds": inputs[5] + (inputs[4] * 10),
                "minutes": inputs[3] + (inputs[2] * 10),
                "hours": inputs[1] + (inputs[0] * 10)]
    }
    
    func renderTime() {
        var timeDict = parseTime()
        
        self.hoursLabel.text = String(format: "%02ld", locale: nil, timeDict["hours"]!)
        self.minutesLabel.text = String(format: "%02ld", locale: nil, timeDict["minutes"]!)
        self.secondsLabel.text = String(format: "%02ld", locale: nil, timeDict["seconds"]!)
    }
    
    private func addTimerActionView() {
        let timerActionView = TimerActionView(frame: CGRectZero, scaledDown: false, needsCancelButton: true)
        timerActionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerActionView)
        self.timerActionView = timerActionView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -20))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 50))
    }

    @IBAction func onDeleteTap() {
        if (timerValue.count > 0) {
            timerValue.removeLast()
            renderTime()
        }
    }
    
    @IBAction func onTimeKeyTap(button: UIButton) {
        if (button.tag == 0 && timerValue.count == 0) { return }
        
        if (timerValue.count < 6) {
            timerValue.append(Int(button.tag))
            renderTime()
        }
    }
    
    func onStartKeyTap() {
        let parsedTime = self.parseTime()
        let totalSeconds = parsedTime["seconds"]! + (parsedTime["minutes"]! * 60) + (parsedTime["hours"]! * 3600)
        
        if (totalSeconds == 0) {
            NSNotificationCenter.defaultCenter().postNotificationName("AltTimerSet", object: self, userInfo: nil)
        } else {
            let actualTimes = ["seconds": totalSeconds % 60, "minutes": (totalSeconds / 60) % 60, "hours": totalSeconds / 3600]
            NSNotificationCenter.defaultCenter().postNotificationName("AltTimerSet", object: self, userInfo: ["times": actualTimes])
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onCancelKeyTap() {
        NSNotificationCenter.defaultCenter().postNotificationName("AltTimerSet", object: self, userInfo: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
