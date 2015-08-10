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
        
        timerControlView.secondSlider.addTarget(self, action: "onSecondsChange:", forControlEvents: UIControlEvents.ValueChanged)
        timerControlView.minuteSlider.addTarget(self, action: "onMinutesChange:", forControlEvents: UIControlEvents.ValueChanged)
        timerControlView.hourSlider.addTarget(self, action: "onHoursChange:", forControlEvents: UIControlEvents.ValueChanged)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let timerProgressVC = segue.destinationViewController as! TimerProgressViewController
        timerProgressVC.timeLeft = timerControlView.getTotalTime()
    }
}

