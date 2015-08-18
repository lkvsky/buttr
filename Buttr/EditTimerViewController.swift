//
//  ViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class EditTimerViewController: UIViewController {
    
    @IBOutlet weak var timerControlView: TimerControlView!
    @IBOutlet weak var timerLabelView: TimerLabelView!
    @IBOutlet weak var startButton: KeyPadControlButton!
    
    var delegate: EditTimerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.startButton.transform = CGAffineTransformMakeScale(0, 0)
        timerControlView.secondSlider.addTarget(self, action: "onSecondsChange:", forControlEvents: UIControlEvents.ValueChanged)
        timerControlView.minuteSlider.addTarget(self, action: "onMinutesChange:", forControlEvents: UIControlEvents.ValueChanged)
        timerControlView.hourSlider.addTarget(self, action: "onHoursChange:", forControlEvents: UIControlEvents.ValueChanged)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "onShowAltEditScreen")
        tapGesture.numberOfTapsRequired = 2;
        self.view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    @IBAction func onStartTap(sender: UIButton) {
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

