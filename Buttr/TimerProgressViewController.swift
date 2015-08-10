//
//  TimerProgressViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/10/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class TimerProgressViewController: UIViewController {
    
    // time left in seconds
    var timeLeft: Int = 60 {
        didSet {
            self.updateTimerLabel()
        }
    }
    
    var timer: NSTimer!
    var timerIsPaused: Bool = false
    
    @IBOutlet var timerProgressView: TimerProgressView!
    @IBOutlet var timerLabelView: TimerLabelView!
    @IBOutlet var timerControlButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.backgroundColor()
        self.timerProgressView.startTimer(duration: timeLeft)
        self.updateTimerLabel()
        
        // start tracking timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }

    func updateTimerLabel() {
        timerLabelView?.seconds = timeLeft % 60
        timerLabelView?.minutes = (timeLeft / 60) % 60
        timerLabelView?.hours = (timeLeft / 3600)
    }
    
    func timerFired() {
        if (timeLeft == 0) {
            timer.invalidate()
            self.timerProgressView.reset()
        } else {
            timeLeft -= 1
            self.timerProgressView.updateSlider()
        }
    }
    
    @IBAction func toggleTimerState() {
        if (timerIsPaused) {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: true)
            timerIsPaused = false
            timerControlButton.setBackgroundImage(UIImage(named: "pause_button"), forState: UIControlState.Normal)
        } else {
            timer.invalidate()
            timerIsPaused = true
            timerControlButton.setBackgroundImage(UIImage(named: "start_button"), forState: UIControlState.Normal)
        }
    }

}
