//
//  ViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class EditTimerViewController: UIViewController {
    
    weak var timerLabelView: TimerLabelView!
    weak var timerControlView: TimerControlView!
    weak var timerActionView: TimerActionView!
    
    var delegate: EditTimerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add subviews and base styles
        self.addTimerControlView()
        self.addTimerLabel()
        self.addTimerActionView()
        self.view.setNeedsUpdateConstraints()
        self.view.backgroundColor = UIColor.backgroundColor()
        self.view.sendSubviewToBack(self.timerLabelView)
        self.timerActionView.transform = CGAffineTransformMakeScale(0, 0)
        
        // initialize gestures and actions
        timerControlView.secondSlider.addTarget(self, action: "onSecondsChange:", forControlEvents: .ValueChanged)
        timerControlView.secondSlider.addTarget(self, action: "onRevolutionCompletion:", forControlEvents: .ApplicationReserved)
        timerControlView.minuteSlider.addTarget(self, action: "onMinutesChange:", forControlEvents: .ValueChanged)
        timerControlView.minuteSlider.addTarget(self, action: "onRevolutionCompletion:", forControlEvents: .ApplicationReserved)
        timerControlView.hourSlider.addTarget(self, action: "onHoursChange:", forControlEvents: .ValueChanged)
        self.timerActionView.startButton.addTarget(self, action: "onSetTimerTap:", forControlEvents: .TouchUpInside)
        self.timerActionView.resetButton.addTarget(self, action: "reset", forControlEvents: .TouchUpInside)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "onShowAltEditScreen:")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Subview Initialization
    
    private func scaleDownViews() -> Bool {
        return self.view.frame.size.width <= 320
    }
    
    private func addTimerControlView() {
        var frameWidth: CGFloat
        
        if (self.scaleDownViews()) {
            frameWidth = self.view.frame.size.height * 1/2
        } else {
            frameWidth = 350
        }
        
        let timerControlView = TimerControlView(frame: CGRectMake(0, 0, frameWidth, frameWidth))
        timerControlView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerControlView)
        self.timerControlView = timerControlView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 8.0))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerLabel() {
        let timerLabelView = TimerLabelView(frame: CGRectZero, scaledDown: self.scaleDownViews())
        timerLabelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerLabelView)
        self.timerLabelView = timerLabelView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant:  self.scaleDownViews() ? 120 : 170))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: self.scaleDownViews() ? 60 : 72))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterX, relatedBy: .Equal, toItem: timerControlView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterY, relatedBy: .Equal, toItem: timerControlView, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerActionView() {
        let timerActionView = TimerActionView(frame: CGRectZero, scaledDown: self.scaleDownViews(), initWithStartShowing: true)
        timerActionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerActionView)
        self.timerActionView = timerActionView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Top, relatedBy: .Equal, toItem: timerControlView, attribute: .Bottom, multiplier: 1.0, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 50))
    }

    // MARK: Gestures and Events
    
    private func didClearTimerValue() {
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.timerActionView.transform = CGAffineTransformMakeScale(0, 0)
        })
        
        self.delegate?.didClearTimerValue(self)
    }
    
    private func didGiveTimerValue() {
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.timerActionView.transform = CGAffineTransformIdentity
        })
        
        self.delegate?.didGiveTimerValue(self)
    }
    
    func onSecondsChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.seconds = newTime == 60 ? 59 : newTime
        timerLabelView.adjustCenterConstraints()
        
        if (self.timerControlView.getTotalTime() == 0) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
    }
    
    func onMinutesChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.minutes = newTime == 60 ? 59 : newTime
        timerLabelView.adjustCenterConstraints()
        
        if (self.timerControlView.getTotalTime() == 0) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
    }
    
    func onHoursChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.hours = newTime == 24 ? 23 : newTime
        timerLabelView.adjustCenterConstraints()
        
        if (self.timerControlView.getTotalTime() == 0) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
    }
    
    func onRevolutionCompletion(slider: CircularSlider) {
        if (slider === timerControlView.secondSlider) {
            timerControlView.minuteSlider.addTimeUnitByAmmount(1)
            timerLabelView.minutes += 1
        } else if (slider === timerControlView.minuteSlider) {
            timerControlView.hourSlider.addTimeUnitByAmmount(1)
            timerLabelView.hours += 1
        }
    }
    
    func onShowAltEditScreen(tap: UITapGestureRecognizer) {
        let touchPoint = tap.locationInView(self.view)
        let labelTouchPoint = self.view.convertPoint(touchPoint, toView: self.timerLabelView)
        
        if (CGRectContainsPoint(self.timerLabelView.bounds, labelTouchPoint)) {
            var altEditTimerVC = AltEditTimerViewController.init(nibName: "AltEditTimerViewController", bundle: nil)
            self.showViewController(altEditTimerVC, sender: self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAltTimerSet:", name: "AltTimerSet", object: nil)
        }
    }
    
    func onAltTimerSet(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let timeSet = userInfo["times"] as! [String: Int]
            timerControlView.resetSliders()
            timerLabelView.setTime(seconds: timeSet["seconds"]!, minutes: timeSet["minutes"]!, hours: timeSet["hours"]!)
            timerControlView.secondSlider.addTimeUnitByAmmount(timeSet["seconds"]!)
            timerControlView.minuteSlider.addTimeUnitByAmmount(timeSet["minutes"]!)
            timerControlView.hourSlider.addTimeUnitByAmmount(timeSet["hours"]!)
            
            if (timerControlView.getTotalTime() == 0) {
                self.didClearTimerValue()
            } else {
                self.didGiveTimerValue()
            }
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onSetTimerTap(sender: UIButton) {
        delegate?.didSetTimer(timerControlView.getTotalTime(), sender: self)
    }
    
    // MARK: Public Methods
    
    func reset() {
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.timerActionView.transform = CGAffineTransformMakeScale(0, 0)
        })
        
        self.timerControlView.resetSliders()
        self.timerLabelView.resetLabel()
        self.delegate?.didClearTimerValue(self)
    }
    
}

protocol EditTimerDelegate {
    func didSetTimer(duration: Int, sender: EditTimerViewController)
    func didGiveTimerValue(sender: EditTimerViewController)
    func didClearTimerValue(sender: EditTimerViewController)
}

