//
//  TimerDoneView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 9/1/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class TimerDoneView: UIView {
    // data
    var timeSinceTimerStopped: Int! {
        didSet {
            self.updateTimeSinceTimerStoppedLabel()
        }
    }
    var dateWhenTimerStopped: NSDate!
    
    // views
    weak var dateWhenTimerStoppedLabel: UILabel!
    weak var timeSinceTimerStoppedLabel: UILabel!
    weak var timeSinceTimerStoppedUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    convenience init(frame: CGRect, dateWhenTimerStopped: NSDate) {
        self.init(frame: frame)
        
        self.addLabels()
        self.timeSinceTimerStopped = Int(NSDate().timeIntervalSinceDate(dateWhenTimerStopped))
        self.dateWhenTimerStopped = dateWhenTimerStopped
        self.renderDate()
        self.updateTimeSinceTimerStoppedLabel()
    }
    
    private func addLabels() {
        let dateWhenTimerStoppedLabel = UILabel()
        let timeSinceTimerStoppedLabel = UILabel()
        let timeSinceTimerStoppedUnitLabel = UILabel()
        
        // add subviews
        self.addSubview(dateWhenTimerStoppedLabel)
        self.addSubview(timeSinceTimerStoppedLabel)
        self.addSubview(timeSinceTimerStoppedUnitLabel)
        
        // store references
        self.dateWhenTimerStoppedLabel = dateWhenTimerStoppedLabel
        self.timeSinceTimerStoppedLabel = timeSinceTimerStoppedLabel
        self.timeSinceTimerStoppedUnitLabel = timeSinceTimerStoppedUnitLabel
        
        // setup constraints and base properties
        for label in [dateWhenTimerStoppedLabel, timeSinceTimerStoppedLabel, timeSinceTimerStoppedUnitLabel] {
            label.textAlignment = .Center
            label.textColor = UIColor.secondaryTextColor()
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        }
        
        // specific properties for dateWhenTimerStoppedLabel
        self.addConstraint(NSLayoutConstraint(item: dateWhenTimerStoppedLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 150))
        self.addConstraint(NSLayoutConstraint(item: dateWhenTimerStoppedLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 30))
        dateWhenTimerStoppedLabel.font = UIFont(name: "Lato-Regular", size: 24)

        // specific properties for timeSinceTimerStoppedLabel
        self.addConstraint(NSLayoutConstraint(item: timeSinceTimerStoppedLabel, attribute: .Top, relatedBy: .Equal, toItem: dateWhenTimerStoppedLabel, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        self.addConstraint(NSLayoutConstraint(item: timeSinceTimerStoppedLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 50))
        timeSinceTimerStoppedLabel.font = UIFont(name: "Lato-Regular", size: 40)

        // specific properties for timeSinceTimerStoppedUnitLabel
        self.addConstraint(NSLayoutConstraint(item: timeSinceTimerStoppedUnitLabel, attribute: .Top, relatedBy: .Equal, toItem: timeSinceTimerStoppedLabel, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: timeSinceTimerStoppedUnitLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 30))
        timeSinceTimerStoppedUnitLabel.font = UIFont(name: "Lato-Light", size: 24)
    }
    
    private func renderDate() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let formattedDate = dateFormatter.stringFromDate(dateWhenTimerStopped)
        let timeStopped = self.dateWhenTimerStopped
        let text = NSString(format: NSString(string: "timer finished at %@"), formattedDate)
        self.dateWhenTimerStoppedLabel.text = String(text)
    }
    
    private func updateTimeSinceTimerStoppedLabel() {
        let seconds = timeSinceTimerStopped % 60
        let minutes = (timeSinceTimerStopped / 60) % 60
        let hours = timeSinceTimerStopped / 3600
        var timeString: NSString!
        
        if (hours > 0) {
            timeString = NSString(format: NSString(string: "%02ld:%02ld:%02ld"), hours, minutes, seconds)
            self.timeSinceTimerStoppedUnitLabel.text = "hrs ago"
        } else if (minutes > 0) {
            timeString = NSString(format: NSString(string: "%02ld:%02ld"), minutes, seconds)
            self.timeSinceTimerStoppedUnitLabel.text = "mins ago"
        } else {
            timeString = NSString(format: NSString(string: "%02ld"), seconds)
            self.timeSinceTimerStoppedUnitLabel.text = "secs ago"
        }
        
        self.timeSinceTimerStoppedLabel.text = String(timeString)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
