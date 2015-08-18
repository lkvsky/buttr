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
    weak var startButton: KeyPadControlButton!
    
    var delegate: EditTimerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add subviews and base styles
        self.addTimerControlView()
        self.addTimerLabel()
        self.addStartButton()
        self.view.setNeedsUpdateConstraints()
        self.view.backgroundColor = UIColor.backgroundColor()
        self.startButton.transform = CGAffineTransformMakeScale(0, 0)
        
        // initialize gestures and actions
        timerControlView.secondSlider.addTarget(self, action: "onSecondsChange:", forControlEvents: .ValueChanged)
        timerControlView.minuteSlider.addTarget(self, action: "onMinutesChange:", forControlEvents: .ValueChanged)
        timerControlView.hourSlider.addTarget(self, action: "onHoursChange:", forControlEvents: .ValueChanged)
        startButton.addTarget(self, action: "onStartTap:", forControlEvents: .TouchUpInside)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "onShowAltEditScreen")
        tapGesture.numberOfTapsRequired = 2;
        self.view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Subview Initialization
    
    private func addTimerControlView() {
        var frameWidth: CGFloat
        
        if (self.view.frame.size.width <= 350) {
            frameWidth = self.view.frame.size.width
            frameWidth = 280
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
        let timerLabelView = TimerLabelView(frame: CGRectMake(0, 0, 170, 72))
        timerLabelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerLabelView)
        self.timerLabelView = timerLabelView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 170))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 72))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterX, relatedBy: .Equal, toItem: timerControlView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterY, relatedBy: .Equal, toItem: timerControlView, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    private func addStartButton() {
        let startButton = KeyPadControlButton(frame: CGRectZero)
        startButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(startButton)
        self.startButton = startButton
        self.startButton.standardBackgroundImage = UIImage(named: "start_button")
        
        self.view.addConstraint(NSLayoutConstraint(item: startButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 120))
        self.view.addConstraint(NSLayoutConstraint(item: startButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 45))
        self.view.addConstraint(NSLayoutConstraint(item: startButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: startButton, attribute: .Top, relatedBy: .Equal, toItem: timerControlView, attribute: .Bottom, multiplier: 1.0, constant: 8))
    }

    // MARK: Gestures and Events
    
    private func didClearTimerValue() {
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.startButton.transform = CGAffineTransformMakeScale(0, 0)
        })
        
        self.delegate?.didClearTimerValue(self)
    }
    
    private func didGiveTimerValue() {
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.startButton.transform = CGAffineTransformIdentity
        })
        
        self.delegate?.didGiveTimerValue(self)
    }
    
    func onSecondsChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);
    
        timerLabelView.seconds = newTime == 60 ? 59 : newTime
        
        if (self.timerControlView.getTotalTime() == 0) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
    }
    
    func onMinutesChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.minutes = newTime == 60 ? 59 : newTime
        
        if (self.timerControlView.getTotalTime() == 0) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
    }
    
    func onHoursChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.hours = newTime == 24 ? 23 : newTime
        
        if (self.timerControlView.getTotalTime() == 0) {
            self.didClearTimerValue()
        } else {
            self.didGiveTimerValue()
        }
    }
    
    func onShowAltEditScreen() {
        var altEditTimerVC = AltEditTimerViewController.init(nibName: "AltEditTimerViewController", bundle: nil)
        self.showViewController(altEditTimerVC, sender: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onAltTimerSet:", name: "AltTimerSet", object: nil)
    }
    
    func onAltTimerSet(notification: NSNotification) {
        let timeSet = notification.userInfo!["times"] as! [String: Int]
        
        self.timerControlView.resetSliders()
        
        timerLabelView.seconds = timeSet["seconds"]!
        timerControlView.secondSlider.addTimeUnitByAmmount(timeSet["seconds"]!)
        
        timerLabelView.minutes = timeSet["minutes"]!
        timerControlView.minuteSlider.addTimeUnitByAmmount(timeSet["minutes"]!)
        
        timerLabelView.hours = timeSet["hours"]!
        timerControlView.hourSlider.addTimeUnitByAmmount(timeSet["hours"]!)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onStartTap(sender: UIButton) {
        delegate?.didSetTimer(timerControlView.getTotalTime(), sender: self)
    }
    
    // MARK: Public Methods
    
    func reset() {
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.startButton.transform = CGAffineTransformMakeScale(0, 0)
        })
        
        self.timerControlView.resetSliders()
        self.timerLabelView.resetLabel()
    }
    
}

protocol EditTimerDelegate {
    func didSetTimer(duration: Int, sender: EditTimerViewController)
    func didGiveTimerValue(sender: EditTimerViewController)
    func didClearTimerValue(sender: EditTimerViewController)
}

