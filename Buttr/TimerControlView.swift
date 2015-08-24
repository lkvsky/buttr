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
    
    let sliderSpacing: CGFloat = 30.0
    
    weak var secondSlider: CircularSlider!
    weak var minuteSlider: CircularSlider!
    weak var hourSlider: CircularSlider!
    
    // MARK: Initialization

    #if TARGET_INTERFACE_BUILDER
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        let origin = self.bounds.origin
        let size = self.bounds.size
        let hourSlider: CircularSlider = CircularSlider(color: UIColor.tertiaryTextColor(), frame: self.bounds)
        let minuteSlider: CircularSlider = CircularSlider(color: UIColor.primaryTextColor(), frame: CGRectMake(origin.x + sliderSpacing, origin.y + sliderSpacing, size.width - 2*sliderSpacing, size.height - 2*sliderSpacing))
        let secondSlider: CircularSlider = CircularSlider(color: UIColor.secondaryTextColor(), frame: CGRectMake(origin.x + 2*sliderSpacing, origin.y + 2*sliderSpacing, size.width - 4*sliderSpacing, size.height - 4*sliderSpacing))
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        self.addSliders()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    #endif
    
    // MARK: Helper Methods
    
    private func addSliders() {
        // instantiate sliders
        let origin = self.bounds.origin
        let size = self.bounds.size
        let hourSlider: CircularSlider = CircularSlider(color: UIColor.tertiaryTextColor(), frame: self.bounds, maxTimeUnits: 24)
        let minuteSlider: CircularSlider = CircularSlider(color: UIColor.primaryTextColor(), frame: CGRectMake(origin.x + sliderSpacing, origin.y + sliderSpacing, size.width - 2*sliderSpacing, size.height - 2*sliderSpacing))
        let secondSlider: CircularSlider = CircularSlider(color: UIColor.secondaryTextColor(), frame: CGRectMake(origin.x + 2*sliderSpacing, origin.y + 2*sliderSpacing, size.width - 4*sliderSpacing, size.height - 4*sliderSpacing))
        
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
    
    func resetSliders() {
        self.secondSlider.angle = Config.BT_STARTING_ANGLE
        self.minuteSlider.angle = Config.BT_STARTING_ANGLE
        self.hourSlider.angle = Config.BT_STARTING_ANGLE
        self.secondSlider.setNeedsDisplay()
        self.minuteSlider.setNeedsDisplay()
        self.hourSlider.setNeedsDisplay()
    }
    
    func animatedTransition() {
        let hourProgress = CircularProgressBar(color: UIColor.tertiaryTextColor(), frame: self.hourSlider.bounds, clockwise: true, drawTracks: true)
        hourProgress.center = hourSlider.center
        hourProgress.currentAngle = hourSlider.angle
        
        let minuteProgress = CircularProgressBar(color: UIColor.primaryTextColor(), frame: self.minuteSlider.bounds, clockwise: true, drawTracks: true)
        minuteProgress.center = minuteSlider.center
        minuteProgress.currentAngle = minuteSlider.angle
        
        let secondProgress = CircularProgressBar(color: UIColor.secondaryTextColor(), frame: self.secondSlider.bounds, clockwise: true, drawTracks: true)
        secondProgress.center = secondSlider.center
        secondProgress.currentAngle = secondSlider.angle
        
        self.addSubview(hourProgress)
        self.addSubview(secondProgress)
        self.addSubview(minuteProgress)
        
        self.hourSlider.layer.opacity = 0
        self.minuteSlider.layer.opacity = 0
        self.secondSlider.layer.opacity = 0
        
        hourProgress.animateProgressBar(endAngle: 91)
        minuteProgress.animateProgressBar(endAngle: 91)
        secondProgress.animateProgressBar(endAngle: 91)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            () -> Void in
            UIView.animateWithDuration(0.125, animations: {
                () -> Void in
                minuteProgress.transform = CGAffineTransformMakeScale(1.2, 1.2)
                secondProgress.transform = CGAffineTransformMakeScale(1.4, 1.4)
                hourProgress.layer.opacity = 0
                secondProgress.layer.opacity = 0
            })
        }
    }
    
    // MARK: Gestures and Events
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let secondsPoint = self.convertPoint(point, toView: secondSlider)
        if (secondSlider.pointInside(secondsPoint, withEvent: event) && secondSlider.touchedSliderPath(secondsPoint)) {
            return secondSlider;
        }
        
        let minutesPoint = self.convertPoint(point, toView: minuteSlider)
        if (minuteSlider.pointInside(minutesPoint, withEvent: event) && minuteSlider.touchedSliderPath(minutesPoint)) {
            return minuteSlider;
        }
        
        let hoursPoint = self.convertPoint(point, toView: hourSlider)
        if (hourSlider.pointInside(hoursPoint, withEvent: event) && hourSlider.touchedSliderPath(hoursPoint)) {
            return hourSlider;
        }
        
        return super.hitTest(point, withEvent: event)
    }
}
