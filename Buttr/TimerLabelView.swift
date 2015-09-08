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
    weak var secondsUnitLabel: UILabel!
    weak var minutesLabel: UILabel!
    weak var minutesUnitLabel: UILabel!
    weak var minutesColon: UILabel!
    weak var hoursLabel: UILabel!
    weak var hoursUnitLabel: UILabel!
    weak var hoursColon: UILabel!
    
    var secondsCenterXConstraint: NSLayoutConstraint!
    var minutesCenterXConstraint: NSLayoutConstraint!
    var hoursCenterXConstraint: NSLayoutConstraint!
    
    var scaledDown: Bool = false
    var renderAllUnits: Bool = false
    
    var seconds: Int = 0 {
        didSet {
            self.secondsLabel.text = self.getFormattedTimeText(seconds)
        }
    }
    
    var minutes: Int = 0 {
        didSet {
            self.minutesLabel.text = self.getFormattedTimeText(minutes)
        }
    }
    
    var hours: Int = 0 {
        didSet {
            self.hoursLabel.text = self.getFormattedTimeText(hours)
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
    
    init(frame: CGRect, scaledDown: Bool = false, renderAllUnits: Bool = false) {
        super.init(frame: frame)
        
        self.scaledDown = scaledDown
        self.renderAllUnits = renderAllUnits
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        
        self.addHoursLabel()
        self.addMinutesLabel()
        self.addSecondsLabel()
        self.addColons()
        
        if (renderAllUnits) {
            self.renderEntireTimeString(CGFloat(170.0 / 3.0))
        } else {
            self.adjustCenterConstraints()
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addSecondsLabel() {
        // set properties
        let secondsLabel = self.createLabel(UIColor.secondaryTextColor())
        secondsLabel.text = self.getFormattedTimeText(seconds)
        
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
        self.secondsUnitLabel = secondsTextLabel
    }
    
    private func addMinutesLabel() {
        // set properties
        let minutesLabel = self.createLabel(UIColor.primaryTextColor())
        minutesLabel.text = self.getFormattedTimeText(minutes)
        minutesLabel.layer.opacity = 0
        
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
        minutesTextLabel.layer.opacity = 0
        self.minutesUnitLabel = minutesTextLabel
    }
    
    private func addHoursLabel() {
        // set properties
        let hoursLabel = self.createLabel(UIColor.tertiaryTextColor())
        hoursLabel.text = self.getFormattedTimeText(hours)
        hoursLabel.layer.opacity = 0
        
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
        hoursTextLabel.layer.opacity = 0
        self.hoursUnitLabel = hoursTextLabel
    }
    
    private func addColons() {
        let minutesColon = self.createLabel(UIColor.primaryTextColor())
        let hoursColon = self.createLabel(UIColor.primaryTextColor())
        
        for label in [minutesColon, hoursColon] {
            label.text = ":"
            label.backgroundColor = UIColor.clearColor()
            label.layer.opacity = 0
            self.addSubview(label)
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 15))
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: minutesLabel, attribute: .Height, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        }
        
        self.minutesColon = minutesColon
        self.hoursColon = hoursColon
        self.addConstraint(NSLayoutConstraint(item: minutesColon, attribute: .Leading, relatedBy: .Equal, toItem: minutesLabel, attribute: .Right, multiplier: 1.0, constant: -4))
        self.addConstraint(NSLayoutConstraint(item: hoursColon, attribute: .Leading, relatedBy: .Equal, toItem: hoursLabel, attribute: .Right, multiplier: 1.0, constant: -4))
    }
    
    // MARK: Label Convenience Methods
    
    private func getFormattedTimeText(time: Int) -> String {
        return String(NSString(format: NSString(string: "%02ld"), time))
    }
    
    private func createLabel(textColor: UIColor) -> UILabel {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont(name: "Lato-Regular", size: self.scaledDown ? 30 : 40)!
        label.textColor = textColor
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = .Center
        label.backgroundColor = UIColor.backgroundColor()
        
        return label
    }
    
    private func createUnitLabel(boundView: UIView, textColor: UIColor) -> UILabel {
        let unitTextLabel = UILabel()
        unitTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        unitTextLabel.font = UIFont(name: "Lato-Light", size: self.scaledDown ? 17 : 24)
        unitTextLabel.textColor = textColor
        unitTextLabel.textAlignment = .Center
        unitTextLabel.backgroundColor = UIColor.backgroundColor()
        
        self.addSubview(unitTextLabel)
        self.addConstraint(NSLayoutConstraint(item: unitTextLabel, attribute: .Width, relatedBy: .Equal, toItem: boundView, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: unitTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem: boundView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: unitTextLabel, attribute: .Top, relatedBy: .Equal, toItem: boundView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        return unitTextLabel
    }
    
    private func setInitialConstraintsForLabel(label: UILabel) {
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1/3, constant: -8))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: -30))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
    }
    
    func resetLabel() {
        self.setTime(seconds: 0, minutes: 0, hours: 0)
    }
    
    func setTime(#seconds: Int, minutes: Int, hours: Int) {
        self.seconds = seconds
        self.minutes = minutes
        self.hours = hours
        
        if (!renderAllUnits) {
            self.adjustCenterConstraints()
        }
    }
    
    func renderEntireTimeString(frameWidth: CGFloat) {
        secondsCenterXConstraint.constant = frameWidth
        minutesCenterXConstraint.constant = 0
        hoursCenterXConstraint.constant = -frameWidth
        minutesLabel.layer.opacity = 1
        minutesUnitLabel.layer.opacity = 1
        hoursLabel.layer.opacity = 1
        hoursUnitLabel.layer.opacity = 1
        minutesColon.layer.opacity = 1
        hoursColon.layer.opacity = 1
    }
    
    // MARK: Constraint animation
    
    func adjustCenterConstraints() {
        var frameWidth: CGFloat
        var numberOfLabels = 0
        
        if (self.frame.size.width > 0) {
            frameWidth = self.frame.size.width / CGFloat(3)
        } else {
            frameWidth = 170 / CGFloat(3)
        }

        if (seconds > 0) {
            numberOfLabels = 1
        }
        
        if (minutes > 0){
            numberOfLabels = 2
        }

        if (hours > 0) {
            numberOfLabels = 3
        }
        
        switch numberOfLabels {
        case 1, 0:
            secondsCenterXConstraint.constant = 0
            minutesCenterXConstraint.constant = 0
            hoursCenterXConstraint.constant = 0
            minutesLabel.layer.opacity = 0
            minutesUnitLabel.layer.opacity = 0
            hoursLabel.layer.opacity = 0
            hoursUnitLabel.layer.opacity = 0
            minutesColon.layer.opacity = 0
            hoursColon.layer.opacity = 0
            break
            
        case 2:
            secondsCenterXConstraint.constant = frameWidth / CGFloat(numberOfLabels)
            minutesCenterXConstraint.constant = -frameWidth / CGFloat(numberOfLabels)
            hoursCenterXConstraint.constant = 0
            minutesLabel.layer.opacity = 1
            minutesUnitLabel.layer.opacity = 1
            hoursLabel.layer.opacity = 0
            hoursUnitLabel.layer.opacity = 0
            minutesColon.layer.opacity = 1
            hoursColon.layer.opacity = 0
            break
            
        case 3:
            self.renderEntireTimeString(frameWidth)
            break
            
        default:
            break
        }
        
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.setNeedsLayout()
        }, completion: nil)
    }
    
}
