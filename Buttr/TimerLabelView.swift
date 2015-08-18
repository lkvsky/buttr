//
//  TimerLabelView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/8/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class TimerLabelView: UIView {
    // MARK: Initialization
    
    weak var secondsLabel: UILabel!
    weak var minutesLabel: UILabel!
    weak var hoursLabel: UILabel!
    
    var secondsCenterXConstraint: NSLayoutConstraint!
    var minutesCenterXConstraint: NSLayoutConstraint!
    var hoursCenterXConstraint: NSLayoutConstraint!
    
    var seconds: Int = 0 {
        didSet {
            self.secondsLabel.text = "\(seconds)"
        }
    }
    
    var minutes: Int = 0 {
        didSet {
            self.minutesLabel.text = "\(minutes)"
            self.adjustCenterConstraints()
        }
    }
    
    var hours: Int = 0 {
        didSet {
            self.hoursLabel.text = "\(hours)"
            self.adjustCenterConstraints()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        
        self.addHoursLabel()
        self.addMinutesLabel()
        self.addSecondsLabel()
    }
    
    func addSecondsLabel() {
        // set properties
        let secondsLabel = self.createLabel(UIColor.secondaryTextColor())
        secondsLabel.text = "\(seconds)"
        
        // add label and store reference
        self.addSubview(secondsLabel)
        self.secondsLabel = secondsLabel
        
        // set constraints
        self.setInitialConstraintsForLabel(self.secondsLabel)
        
        // we'll be animating the centerX constraint depending on the time displayed
        self.secondsCenterXConstraint = NSLayoutConstraint(item: self.secondsLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(self.secondsCenterXConstraint)
        
        // create unit type label
        let secondsTextLabel = self.createUnitLabel(secondsLabel, textColor: UIColor.secondaryTextColor())
        secondsTextLabel.text = "secs"
    }
    
    func addMinutesLabel() {
        // set properties
        let minutesLabel = self.createLabel(UIColor.primaryTextColor())
        minutesLabel.text = "\(minutes)"
        
        // add label and store reference
        self.addSubview(minutesLabel)
        self.minutesLabel = minutesLabel
        
        // set constraints
        self.setInitialConstraintsForLabel(self.minutesLabel)
        
        // we'll be animating the centerX constraint depending on the time displayed
        self.minutesCenterXConstraint = NSLayoutConstraint(item: self.minutesLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(self.minutesCenterXConstraint)
        
        // create unit type label
        let minutesTextLabel = self.createUnitLabel(minutesLabel, textColor: UIColor.primaryTextColor())
        minutesTextLabel.text = "mins"
    }
    
    func addHoursLabel() {
        // set properties
        let hoursLabel = self.createLabel(UIColor.tertiaryTextColor())
        
        // add label and store reference
        self.addSubview(hoursLabel)
        self.hoursLabel = hoursLabel
        
        // set constraints
        self.setInitialConstraintsForLabel(self.hoursLabel)
        
        // we'll be animating the centerX constraint depending on the time displayed
        self.hoursCenterXConstraint = NSLayoutConstraint(item: self.hoursLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(self.hoursCenterXConstraint)
        
        // create unit type label
        let hoursTextLabel = self.createUnitLabel(hoursLabel, textColor: UIColor.tertiaryTextColor())
        hoursTextLabel.text = "hrs"
    }
    
    // MARK: Label Convenience Methods
    
    func createLabel(textColor: UIColor) -> UILabel {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont(name: "Lato", size: 40.0)!
        label.textColor = textColor
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = .Center
        label.backgroundColor = UIColor.backgroundColor()
        
        return label
    }
    
    func createUnitLabel(boundView: UIView, textColor: UIColor) -> UILabel {
        let unitTextLabel = UILabel()
        unitTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        unitTextLabel.font = UIFont(name: "Lato-Regular", size: 17)
        unitTextLabel.textColor = textColor
        unitTextLabel.textAlignment = .Center
        unitTextLabel.backgroundColor = UIColor.backgroundColor()
        
        self.addSubview(unitTextLabel)
        self.addConstraint(NSLayoutConstraint(item: unitTextLabel, attribute: .Width, relatedBy: .Equal, toItem: boundView, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: unitTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem: boundView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: unitTextLabel, attribute: .Top, relatedBy: .Equal, toItem: boundView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        return unitTextLabel
    }
    
    func setInitialConstraintsForLabel(label: UILabel) {
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1/3, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: -30))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
    }
    
    func resetLabel() {
        self.seconds = 0
        self.minutes = 0
        self.hours = 0
    }
    
    // MARK: Constraint animation
    
    func adjustCenterConstraints() {
        var frameWidth = self.frame.size.width / CGFloat(3)
        var numberOfLabels = 1

        if (minutes > 0){
            numberOfLabels = 2
        }

        if (hours > 0) {
            numberOfLabels = 3
        }
        
        switch numberOfLabels {
        case 1:
            secondsCenterXConstraint.constant = 0
            minutesCenterXConstraint.constant = 0
            hoursCenterXConstraint.constant = 0
            break
            
        case 2:
            secondsCenterXConstraint.constant = frameWidth / CGFloat(numberOfLabels)
            minutesCenterXConstraint.constant = -frameWidth / CGFloat(numberOfLabels)
            hoursCenterXConstraint.constant = 0
            break
            
        case 3:
            secondsCenterXConstraint.constant = frameWidth
            minutesCenterXConstraint.constant = 0
            hoursCenterXConstraint.constant = -frameWidth
            break
            
        default:
            break
        }
        
        UIView.animateWithDuration(0.125, animations: { () -> Void in
            self.setNeedsUpdateConstraints()
        })
    }
    
}
