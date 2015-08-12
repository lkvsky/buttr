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
    @IBOutlet var timeKeys: [UIButton]!
    @IBOutlet var startKey: UIButton!
    @IBOutlet var cancelKey: UIButton!
    
    // labels
    @IBOutlet var timerLabels: [UILabel]!
    @IBOutlet var secondsLabel: UILabel!
    @IBOutlet var minutesLabel: UILabel!
    @IBOutlet var hoursLabel: UILabel!
    
    // data
    var timerValue: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.timerLabels.map { (label: UILabel) -> UILabel in
            label.textColor = UIColor.primaryTextColor()
            return label
        }
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

    @IBAction func onCancelTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTimeKeyTap(button: UIButton) {
        if (timerValue.count < 6) {
            timerValue.append(Int(button.tag))
            renderTime()
        }
    }
    
    @IBAction func onStartKeyTap() {
        NSNotificationCenter.defaultCenter().postNotificationName("AltTimerSet", object: self, userInfo: ["times": self.parseTime()])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
