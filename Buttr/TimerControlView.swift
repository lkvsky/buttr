//
//  TimerView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

@IBDesignable class TimerControlView: UIView {
    
    // MARK: Properties
    
    let sliderSpacing: CGFloat = 25.0
    
    var secondSlider: CircularSlider!
    var minuteSlider: CircularSlider!
    var hourSlider: CircularSlider!
    
    // MARK: Initialization

    #if TARGET_INTERFACE_BUILDER
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        let origin = self.bounds.origin
        let size = self.bounds.size
        let hourSlider: CircularSlider = CircularSlider(color: UIColor.tertiaryTextColor(), frame: self.bounds)
        let minuteSlider: CircularSlider = CircularSlider(color: UIColor.secondaryTextColor(), frame: CGRectMake(origin.x + sliderSpacing, origin.y + sliderSpacing, size.width - 2*sliderSpacing, size.height - 2*sliderSpacing))
        let secondSlider: CircularSlider = CircularSlider(color: UIColor.primaryTextColor(), frame: CGRectMake(origin.x + 2*sliderSpacing, origin.y + 2*sliderSpacing, size.width - 4*sliderSpacing, size.height - 4*sliderSpacing))
    
        self.addSubview(hourSlider)
        self.addSubview(minuteSlider)
        self.addSubview(secondSlider)
    }
    
    #else
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        self.addSliders()
    }
    
    #endif
    
    // MARK: Helper Methods
    
    func addSliders() {
        // instantiate sliders
        let origin = self.bounds.origin
        let size = self.bounds.size
        let hourSlider: CircularSlider = CircularSlider(color: UIColor.tertiaryTextColor(), frame: self.bounds)
        let minuteSlider: CircularSlider = CircularSlider(color: UIColor.secondaryTextColor(), frame: CGRectMake(origin.x + sliderSpacing, origin.y + sliderSpacing, size.width - 2*sliderSpacing, size.height - 2*sliderSpacing))
        let secondSlider: CircularSlider = CircularSlider(color: UIColor.primaryTextColor(), frame: CGRectMake(origin.x + 2*sliderSpacing, origin.y + 2*sliderSpacing, size.width - 4*sliderSpacing, size.height - 4*sliderSpacing))
        
        // add to view
        self.addSubview(hourSlider)
        self.addSubview(minuteSlider)
        self.addSubview(secondSlider)
        
        // store references
        self.hourSlider = hourSlider
        self.minuteSlider = minuteSlider
        self.secondSlider = secondSlider
    }
    
    // MARK: Public Methods
    
    func getTotalTime() -> Int {
        return secondSlider.getTimeUnitFromAngleInt(secondSlider.angle) + (minuteSlider.getTimeUnitFromAngleInt(minuteSlider.angle) * 60) + (hourSlider.getTimeUnitFromAngleInt(hourSlider.angle) * 3600)
    }
    
    // MARK: Gestures and Events
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let secondsPoint = self.convertPoint(point, toView: secondSlider)
        if (secondSlider.pointInside(secondsPoint, withEvent: event) && CGRectContainsPoint(secondSlider.rectForHandle(), secondsPoint)) {
            return secondSlider;
        }
        
        let minutesPoint = self.convertPoint(point, toView: minuteSlider)
        if (minuteSlider.pointInside(minutesPoint, withEvent: event) && CGRectContainsPoint(minuteSlider.rectForHandle(), minutesPoint)) {
            return minuteSlider;
        }
        
        let hoursPoint = self.convertPoint(point, toView: hourSlider)
        if (hourSlider.pointInside(hoursPoint, withEvent: event) && CGRectContainsPoint(hourSlider.rectForHandle(), hoursPoint)) {
            return hourSlider;
        }
        
        return super.hitTest(point, withEvent: event)
    }
}
