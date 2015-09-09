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
    var scaledDown: Bool = false
    
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
    
    convenience init(frame: CGRect, dateWhenTimerStopped: NSDate, scaledDown: Bool = false) {
        self.init(frame: frame)
        
        self.dateWhenTimerStopped = dateWhenTimerStopped
        self.scaledDown = scaledDown
        self.addLabels()
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
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        dateWhenTimerStoppedLabel.font = UIFont(name: "Lato-Black", size: 18)
        self.renderDate(dateWhenTimerStoppedLabel)
    }
    
    private func renderDate(label: UILabel) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let formattedDate = dateFormatter.stringFromDate(dateWhenTimerStopped)
        let timeStopped = self.dateWhenTimerStopped
        let text = NSString(format: NSString(string: "timer ended at %@"), formattedDate)
        label.text = String(text)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
