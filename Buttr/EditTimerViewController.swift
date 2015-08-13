//
//  ViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class EditTimerViewController: UIViewController {
    
    @IBOutlet var timerControlView: TimerControlView!
    @IBOutlet var timerLabelView: TimerLabelView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.view.sendSubviewToBack(timerLabelView)
        
        timerControlView.secondSlider.addTarget(self, action: "onSecondsChange:", forControlEvents: UIControlEvents.ValueChanged)
        timerControlView.minuteSlider.addTarget(self, action: "onMinutesChange:", forControlEvents: UIControlEvents.ValueChanged)
        timerControlView.hourSlider.addTarget(self, action: "onHoursChange:", forControlEvents: UIControlEvents.ValueChanged)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "showAltEditScreen")
        tapGesture.numberOfTapsRequired = 2;
        self.timerControlView.addGestureRecognizer(tapGesture)
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
    
    func showAltEditScreen() {
        var altEditTimerVC = AltEditTimerViewController.init(nibName: "AltEditTimerViewController", bundle: nil)
        self.showViewController(altEditTimerVC, sender: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "altTimerSet:", name: "AltTimerSet", object: nil)
    }
    
    func altTimerSet(notification: NSNotification) {
        let timeSet = notification.userInfo!["times"] as! [String: Int]
        
        timerLabelView.seconds = timeSet["seconds"]!
        timerControlView.secondSlider.addTimeUnitByAmmount(timeSet["seconds"]!)
        
        timerLabelView.minutes = timeSet["minutes"]!
        timerControlView.minuteSlider.addTimeUnitByAmmount(timeSet["minutes"]!)
        
        timerLabelView.hours = timeSet["hours"]!
        timerControlView.hourSlider.addTimeUnitByAmmount(timeSet["hours"]!)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let timerProgressVC = segue.destinationViewController as! TimerProgressViewController
        timerProgressVC.timeLeft = timerControlView.getTotalTime()
    }
}

