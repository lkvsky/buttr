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
    
    var delegate: EditTimerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        
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
    
    func onSecondsChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);
    
        timerLabelView.seconds = newTime == 60 ? 59 : newTime
    }
    
    func onMinutesChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.minutes = newTime == 60 ? 59 : newTime
    }
    
    func onHoursChange(slider: CircularSlider) {
        var newTime = slider.getTimeUnitFromAngleInt(slider.angle);

        timerLabelView.hours = newTime == 60 ? 59 : newTime
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
        self.timerControlView.resetSliders()
        self.timerLabelView.resetLabel()
    }
    
}

protocol EditTimerDelegate {
    func didSetTimer(duration: Int, sender: EditTimerViewController)
}

