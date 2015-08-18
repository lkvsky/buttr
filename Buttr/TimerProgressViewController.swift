//
//  TimerProgressViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/10/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class TimerProgressViewController: UIViewController {
    
    // time left in seconds
    var timeLeft: Int! {
        didSet {
            self.updateTimerLabel()
            
            if let warnings = self.timerProgressView?.warningSlider?.warningTimes {
                for warningTime in warnings {
                    if (timeLeft == (Int(self.timer.duration) - warningTime)) {
                        self.alert()
                    }
                }
            }
        }
    }
    
    var timer: Timer!
    var nsTimerInstance: NSTimer!
    var timerIsPaused: Bool = false
    
    // alarm properties
    var nsTimerAlertInstance: NSTimer!
    var audioPlayer: AVAudioPlayer!
    var butterBark: SystemSoundID = 0
    
    weak var timerProgressView: TimerProgressView!
    weak var timerLabelView: TimerLabelView!
    weak var timerControlButton: KeyPadControlButton!
    
    var delegate: TimerProgressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add subviews and setup properties
        self.addTimerProgressView()
        self.addTimerLabel()
        self.addTimerControlButton()
        self.view.setNeedsUpdateConstraints()
        self.view.backgroundColor = UIColor.backgroundColor()

        // init actions and animation
        self.timeLeft = self.timer.timeLeft()
        self.timerProgressView.startTimer(duration: Int(self.timer.duration), timeLeft: self.timer.timeLeft(), warnings: self.timer.getWarningsAsInts())
        self.updateTimerLabel()
        self.timerControlButton.addTarget(self, action: "toggleTimerState", forControlEvents: .TouchUpInside)
        self.timerProgressView.warningSlider.addTarget(self, action: "onWarningsChange:", forControlEvents: .ValueChanged)

        
        // start tracking timer
        nsTimerInstance = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    deinit {
        self.invalidateTimersAndAlerts()
    }

    func updateTimerLabel() {
        timerLabelView?.seconds = timeLeft % 60
        timerLabelView?.minutes = (timeLeft / 60) % 60
        timerLabelView?.hours = (timeLeft / 3600)
    }
    
    func playButterBark() {
        let butterPath = NSBundle.mainBundle().pathForResource("butter_bark", ofType: "wav")
        let butterUrl = NSURL.fileURLWithPath(butterPath!)
        audioPlayer = AVAudioPlayer(contentsOfURL: butterUrl!, error: nil)
        
        audioPlayer.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        nsTimerAlertInstance = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "alert", userInfo: nil, repeats: true)
    }
    
    func alert() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // MARK: Subview Initialization
    
    private func addTimerProgressView() {
        var frameWidth: CGFloat
        
        if (self.view.frame.size.width <= 350) {
            frameWidth = self.view.frame.size.width
            frameWidth = 280
        } else {
            frameWidth = 350
        }
        
        let timerProgressView = TimerProgressView(frame: CGRectMake(0, 0, frameWidth, frameWidth))
        timerProgressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerProgressView)
        self.timerProgressView = timerProgressView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 8.0))
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerLabel() {
        let timerLabelView = TimerLabelView(frame: CGRectMake(0, 0, 170, 72))
        timerLabelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerLabelView)
        self.timerLabelView = timerLabelView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 170))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 72))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterX, relatedBy: .Equal, toItem: timerProgressView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterY, relatedBy: .Equal, toItem: timerProgressView, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerControlButton() {
        let timerControlButton = KeyPadControlButton(frame: CGRectZero)
        timerControlButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerControlButton)
        self.timerControlButton = timerControlButton
        self.timerControlButton.standardBackgroundImage = UIImage(named: "pause_button")
        
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 120))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 45))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .Top, relatedBy: .Equal, toItem: timerProgressView, attribute: .Bottom, multiplier: 1.0, constant: 8))
    }
    
    // MARK: Gestures and Events
    
    func timerFired() {
        if (timeLeft == 0) {
            self.playButterBark()
            nsTimerInstance.invalidate()
            self.delegate?.didFinishTimer(self)
        } else {
            timeLeft = self.timer.timeLeft()
            self.timerProgressView.updateSlider()
        }
    }
    
    func toggleTimerState() {
        if (timerIsPaused) {
            self.timer.resetStartTime()
            DataManager.sharedInstance.save()

            nsTimerInstance = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: true)
            timerIsPaused = false
            timerControlButton.standardBackgroundImage = UIImage(named: "pause_button")
        } else {
            self.timer.pauseTime = NSDate()
            DataManager.sharedInstance.save()
            
            nsTimerInstance.invalidate()
            timerIsPaused = true
            timerControlButton.standardBackgroundImage = UIImage(named: "start_button")
        }
    }
    
    func onWarningsChange(slider: WarningSlider) {
        // TODO: Store warnigns and set alarms accordingly
        self.timer.addWarnings(slider.warningTimes)
        DataManager.sharedInstance.save()
    }
    
    // MARK: Public Methods
    
    func reset() {
        self.timer.canceled = 1
        DataManager.sharedInstance.save()
        self.invalidateTimersAndAlerts()
    }
    
    func invalidateTimersAndAlerts() {
        audioPlayer?.stop()
        nsTimerAlertInstance?.invalidate()
        nsTimerInstance?.invalidate()
    }

}

protocol TimerProgressDelegate {
    func didFinishTimer(sender: TimerProgressViewController)
}
