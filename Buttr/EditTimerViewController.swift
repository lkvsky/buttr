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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "launchTimerIfNecessary", name: UIApplicationWillEnterForegroundNotification, object: nil)
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
    
    func launchTimerIfNecessary() {
        if let timer = Timer.getCurrentTimer() {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let timerProgressVC = storyBoard.instantiateViewControllerWithIdentifier("TimerProgressViewController") as! TimerProgressViewController
            timerProgressVC.timer = timer
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.showViewController(timerProgressVC, sender: self)
            })
        }
    }
    
    @IBAction func onTapRest() {
        self.timerControlView.resetSliders()
        self.timerLabelView.resetLabel()
    }
    
    func showAltEditScreen() {
        var altEditTimerVC = AltEditTimerViewController.init(nibName: "AltEditTimerViewController", bundle: nil)
        self.showViewController(altEditTimerVC, sender: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "altTimerSet:", name: "AltTimerSet", object: nil)
    }
    
    func altTimerSet(notification: NSNotification) {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let timer = Timer(context: DataManager.sharedInstance.mainMoc)
        timer.duration = timerControlView.getTotalTime()
        timer.startTime = NSDate()
        DataManager.sharedInstance.save()
        
        let timerProgressVC = segue.destinationViewController as! TimerProgressViewController
        timerProgressVC.timer = timer
    }
}

