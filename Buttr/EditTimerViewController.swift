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
        timerControlView.minuteSlider.addTarget(self, action: "onMinutesChange:", forControlEvents: .ValueChanged)
        timerControlView.hourSlider.addTarget(self, action: "onHoursChange:", forControlEvents: .ValueChanged)
        self.timerActionView.startButton.addTarget(self, action: "onSetTimerTap", forControlEvents: .TouchUpInside)
        self.timerActionView.resetButton.addTarget(self, action: "reset", forControlEvents: .TouchUpInside)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onRevolutionCompletion:", name: "UserPassedStartingAngle", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onRegisterNotifications:", name: "UserRegisteredNotifications", object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "onShowAltEditScreen:")
        self.view.addGestureRecognizer(tapGesture)
        
        // check if a user has set a timer before.
        // if not, render instructional dialogue
        let userPrefs = NSUserDefaults.standardUserDefaults()
        let userHasSeenSetTimerDialogue = userPrefs.objectForKey("UserHasSeenSetTimerDialogue") != nil
        
        if (!userHasSeenSetTimerDialogue) {
            self.delegate?.shouldRenderSetTimerDialogue(self)
            userPrefs.setObject(1, forKey: "UserHasSeenSetTimerDialogue")
            userPrefs.synchronize()
        }
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
        timerControlView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(timerControlView)
        self.timerControlView = timerControlView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 8.0))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerLabel() {
        let timerLabelView = TimerLabelView(frame: CGRectZero, scaledDown: self.scaleDownViews(), renderAllUnits: true)
        timerLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(timerLabelView)
        self.timerLabelView = timerLabelView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant:  self.scaleDownViews() ? 120 : 170))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: self.scaleDownViews() ? 60 : 72))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterX, relatedBy: .Equal, toItem: timerControlView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterY, relatedBy: .Equal, toItem: timerControlView, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerActionView() {
        let timerActionView = TimerActionView(frame: CGRectZero, scaledDown: self.scaleDownViews())
        timerActionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(timerActionView)
        self.timerActionView = timerActionView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Top, relatedBy: .Equal, toItem: timerControlView, attribute: .Bottom, multiplier: 1.0, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
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
    
    func onTimeChange() {
        let totalTime = self.timerControlView.getTotalTime()
        let timeIsZero = totalTime == 0
        
        if (timeIsZero) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
        
        timerControlView.secondSlider.canMoveBackwards = totalTime > 0
        timerControlView.minuteSlider.canMoveBackwards = totalTime >= 60
        timerControlView.hourSlider.canMoveBackwards = totalTime >= 3600
    }
    
    func onSecondsChange(slider: CircularSlider) {
        let newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.seconds = newTime == 60 ? 0 : newTime
        self.onTimeChange()
    }
    
    func onMinutesChange(slider: CircularSlider) {
        let newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.minutes = newTime == 60 ? 0 : newTime
        self.onTimeChange()
    }
    
    func onHoursChange(slider: CircularSlider) {
        let newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.hours = newTime == 24 ? 0 : newTime
        self.onTimeChange()
    }
    
    func onRevolutionCompletion(notification: NSNotification) {
        let direction = notification.userInfo!["direction"] as! Int
        
        if (notification.object === timerControlView.secondSlider) {
            let newMinutes = timerLabelView.minutes + direction
            
            if (newMinutes >= 0) {
                // check if user has spun enough to set 60 minutes. if so, clear minutes and add an hour
                if (newMinutes == timerControlView.minuteSlider.maxTimeUnits && timerLabelView.hours < timerControlView.hourSlider.maxTimeUnits) {
                    timerControlView.hourSlider.addTimeUnitByAmmount(direction)
                    timerLabelView.hours += direction
                    
                    timerLabelView.minutes = 0
                    timerControlView.minuteSlider.angle = Config.BT_STARTING_ANGLE
                    timerControlView.minuteSlider.setNeedsDisplay()
                }
                // else make sure that the new minutes value is less than the max allowed
                else if (newMinutes < timerControlView.minuteSlider.maxTimeUnits) {
                    timerControlView.minuteSlider.addTimeUnitByAmmount(direction)
                    timerLabelView.minutes += direction
                }
            }
        } else if (notification.object === timerControlView.minuteSlider) {
            // make sure that the hours value is neither negative nor above the allowed max
            if (timerLabelView.hours + direction >= 0 && timerLabelView.hours + direction < timerControlView.hourSlider.maxTimeUnits) {
                timerControlView.hourSlider.addTimeUnitByAmmount(direction)
                timerLabelView.hours += direction
            }
        }
    }
    
    func onShowAltEditScreen(tap: UITapGestureRecognizer) {
        let touchPoint = tap.locationInView(self.view)
        let labelTouchPoint = self.view.convertPoint(touchPoint, toView: self.timerLabelView)
        
        if (CGRectContainsPoint(self.timerLabelView.bounds, labelTouchPoint)) {
            let altEditTimerVC = AltEditTimerViewController.init(nibName: "AltEditTimerViewController", bundle: nil)
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
                self.onSetTimerTap()
            }
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AltTimerSet", object: nil)
    }
    
    func onSetTimerTap() {
        if (UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            let notificationCategory = UIMutableUserNotificationCategory()
            notificationCategory.identifier = "BUTTR_ALERT_CATEGORY"
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes:[UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))
        }
    }
    
    func onRegisterNotifications(notification: NSNotification) {
        let userPrefs = NSUserDefaults.standardUserDefaults()
        userPrefs.setObject(1, forKey: "HasRegisteredNotifications")
        userPrefs.synchronize()
        
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
    func shouldRenderSetTimerDialogue(sender: EditTimerViewController)
}

