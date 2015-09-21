//
//  TimerDoneView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 9/1/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class TimerDoneView: UIView {
    var dateWhenTimerStopped: NSDate!
    var dateWhenTimerStoppedLabel: UILabel!
    var scaledDown: Bool = false
    var timeSinceEndingTimer: NSTimer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    convenience init(frame: CGRect, dateWhenTimerStopped: NSDate, scaledDown: Bool = false) {
        self.init(frame: frame)
        
        self.dateWhenTimerStopped = dateWhenTimerStopped
        self.scaledDown = scaledDown
        self.addLabels()
        self.timeSinceEndingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "renderDate", userInfo: nil, repeats: true)
    }
    
    deinit {
        self.timeSinceEndingTimer.invalidate()
    }
    
    func addLabels() {
        let dateWhenTimerStoppedLabel = UILabel()
        let timesUpLabel = UILabel()
        
        // add subviews
        self.addSubview(dateWhenTimerStoppedLabel)
        self.addSubview(timesUpLabel)
        
        // setup constraints and base properties
        for label in [dateWhenTimerStoppedLabel, timesUpLabel] {
            label.textAlignment = .Center
            label.textColor = UIColor.primaryTextColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        }
        
        // specific properties for timesUpLabel
        self.addConstraint(NSLayoutConstraint(item: timesUpLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 200))
        self.addConstraint(NSLayoutConstraint(item: timesUpLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 72))
        timesUpLabel.font = UIFont(name: "Lato-Black", size: self.scaledDown ? 40 : 60)
        timesUpLabel.text = "TIME'S UP!"
        
        // specific properties for dateWhenTimerStoppedLabel
        self.addConstraint(NSLayoutConstraint(item: dateWhenTimerStoppedLabel, attribute: .Top, relatedBy: .Equal, toItem: timesUpLabel, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: dateWhenTimerStoppedLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 22))
        dateWhenTimerStoppedLabel.font = UIFont(name: "Lato-Regular", size: 18)
        self.dateWhenTimerStoppedLabel = dateWhenTimerStoppedLabel
        self.renderDate()
    }
    
    func renderDate() {
        let timeSinceTimerStopped = Int(NSDate().timeIntervalSinceDate(self.dateWhenTimerStopped))
        let seconds = timeSinceTimerStopped % 60
        let minutes = (timeSinceTimerStopped / 60) % 60
        let hours = timeSinceTimerStopped / 3600
        var timeString: NSString!
        
        if (hours > 0) {
            timeString = NSString(format: NSString(string: "%02ld:%02ld:%02ld hrs ago"), hours, minutes, seconds)
        } else if (minutes > 0) {
            timeString = NSString(format: NSString(string: "%02ld:%02ld mins ago"), minutes, seconds)
        } else {
            timeString = NSString(format: NSString(string: "%02ld secs ago"), seconds)
        }
        
        let text = NSString(format: NSString(string: "timer ended %@"), timeString)
        dateWhenTimerStoppedLabel.text = String(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
