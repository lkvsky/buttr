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
            self.timerProgressView.updateProgressBar()
            
            if let warnings = self.timerProgressView?.warningSlider?.warningTimes {
                for warningTime in warnings {
                    if (timeLeft == warningTime) {
                        self.fireWarning()
                        self.timerProgressView.warningSlider.removeFiredWarnings()
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
    var butterBarker: AVAudioPlayer!
    var butterGrowler: AVAudioPlayer!
    var butterBark: SystemSoundID = 0
    var butterGrowl: SystemSoundID = 0
    
    weak var timerProgressView: TimerProgressView!
    weak var timerLabelView: TimerLabelView!
    weak var timerDoneView: TimerDoneView!
    weak var timerActionView: TimerActionView!
    
    var delegate: TimerProgressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.setNeedsUpdateConstraints()
        self.view.backgroundColor = UIColor.backgroundColor()
        
        // start tracking timer
        if (self.timer.isDone()) {
            self.setTimerDoneState()
        } else {
            // add subviews
            self.addTimerProgressView()
            self.addTimerLabel()
            self.addTimerActionView()
            self.view.sendSubviewToBack(self.timerLabelView)
            
            // init actions and animation
            self.timeLeft = self.timer.timeLeft()
            self.timerProgressView.setupTimerProgressView(duration: Int(self.timer.duration), timeLeft: self.timer.timeLeft(), warnings: self.timer.getWarningsAsInts())
            self.timerProgressView.warningSlider.addTarget(self, action: "onWarningsChange:", forControlEvents: .ValueChanged)
            self.timerActionView.startButton.addTarget(self, action: "toggleTimerState", forControlEvents: .TouchUpInside)
            self.timerActionView.pauseButton.addTarget(self, action: "toggleTimerState", forControlEvents: .TouchUpInside)
            self.timerActionView.resetButton.addTarget(self, action: "reset", forControlEvents: .TouchUpInside)
            
            if (self.timer.isPaused.boolValue) {
                self.setPausedTimerState()
            } else if (self.timer.hasStarted()) {
                self.setTimerRestartState()
            }
            
            // check if user has seen warning instructions before
            // if not, render dialogue
            var userPrefs = NSUserDefaults.standardUserDefaults()
            var userHasSeenWarningInstructions = userPrefs.objectForKey("UserHasSeenWarningInstructions") != nil
            
            if (!userHasSeenWarningInstructions) {
                userPrefs.setObject(1, forKey: "UserHasSeenWarningInstructions")
                self.delegate?.shouldShowSetWarningPrompt(self)
            }
        }
    }
    
    deinit {
        self.invalidateTimersAndAlerts()
    }

    func updateTimerLabel() {
        timerLabelView?.setTime(seconds: timeLeft % 60, minutes: (timeLeft / 60) % 60, hours: (timeLeft / 3600))
    }
    
    func fireTimerEndAlert() {
        let butterPath = NSBundle.mainBundle().pathForResource("butter_bark", ofType: "wav")
        let butterUrl = NSURL.fileURLWithPath(butterPath!)
        butterBarker = AVAudioPlayer(contentsOfURL: butterUrl!, error: nil)
        
        butterBarker.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        nsTimerAlertInstance = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "vibrate", userInfo: nil, repeats: true)
    }
    
    func fireWarning() {
        if let warningAudio = butterGrowler {
            warningAudio.play()
        } else {
            let butterPath = NSBundle.mainBundle().pathForResource("butter_growl", ofType: "wav")
            let butterUrl = NSURL.fileURLWithPath(butterPath!)
            butterGrowler = AVAudioPlayer(contentsOfURL: butterUrl!, error: nil)
            butterGrowler.play()
        }
        
        self.vibrate()
        self.delegate?.didFireWarning(self)
    }
    
    func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // MARK: Subview Initialization
    
    private func scaleDownViews() -> Bool {
        return self.view.frame.size.width <= 320
    }
    
    private func addTimerProgressView() {
        var frameWidth: CGFloat
        
        if (self.scaleDownViews()) {
            frameWidth = self.view.frame.size.height * 1/2
        } else {
            frameWidth = 350
        }
        
        let timerProgressView = TimerProgressView(frame: CGRectMake(0, 0, frameWidth, frameWidth))
        timerProgressView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerProgressView)
        self.timerProgressView = timerProgressView
        self.constrainMainView(timerProgressView, frameWidth: frameWidth)
    }
    
    private func addTimerLabel() {
        let timerLabelView = TimerLabelView(frame: CGRectZero, scaledDown: self.scaleDownViews())
        timerLabelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerLabelView)
        self.timerLabelView = timerLabelView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: self.scaleDownViews() ? 120 : 170))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: self.scaleDownViews() ? 60 : 72))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterX, relatedBy: .Equal, toItem: timerProgressView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerLabelView, attribute: .CenterY, relatedBy: .Equal, toItem: timerProgressView, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerActionView() {
        let timerActionView = TimerActionView(frame: CGRectZero, scaledDown: self.scaleDownViews(), initWithStartShowing: true)
        timerActionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerActionView)
        self.timerActionView = timerActionView
        
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Top, relatedBy: .Equal, toItem: timerProgressView, attribute: .Bottom, multiplier: 1.0, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerActionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 50))
    }
    
    private func addTimerDoneView() {
        var frameWidth = CGFloat(350)
        
        let timerDoneView = TimerDoneView(frame: CGRectMake(0, 0, 350, 350), dateWhenTimerStopped: self.timer.projectedEndDate(), scaledDown: self.scaleDownViews())
        timerDoneView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(timerDoneView)
        self.timerDoneView = timerDoneView
        self.constrainMainView(timerDoneView, frameWidth: frameWidth)
    }
    
    private func constrainMainView(mainView: UIView, frameWidth: CGFloat) {
        self.view.addConstraint(NSLayoutConstraint(item: mainView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: mainView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: mainView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 8.0))
        self.view.addConstraint(NSLayoutConstraint(item: mainView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    
    func setPausedTimerState() {
        nsTimerInstance?.invalidate()
        timerIsPaused = true
        self.timerActionView.showStartAndResetButtons()
        self.delegate?.didPauseTimer(self)
    }
    
    func setTimerRestartState() {
        nsTimerInstance = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timeLeftHasDecreased", userInfo: nil, repeats: true)
        timerIsPaused = false
        self.timerActionView.showPauseButton()
        self.delegate?.didRestartTimer(self)
    }
    
    func setTimerDoneState() {
        self.timerProgressView?.removeFromSuperview()
        self.timerLabelView?.removeFromSuperview()
        self.timerActionView?.removeFromSuperview()
        self.addTimerDoneView()
        self.delegate?.didFinishTimer(self)
    }
    
    // MARK: Gestures and Events
    
    func timeLeftHasDecreased() {
        if (timeLeft == 0) {
            self.fireTimerEndAlert()
            nsTimerInstance.invalidate()
            self.setTimerDoneState()
        } else {
            timeLeft = self.timer.timeLeft()
        }
    }
    
    func toggleTimerState() {
        if (!self.timer.hasStarted()) {
            self.timer.startTime = NSDate()
            DataManager.sharedInstance.save()
            self.timeLeftHasDecreased()
            self.setTimerRestartState()
        } else if (timerIsPaused) {
            self.timer.isPaused = NSNumber(bool: false)
            self.timer.resetStartTime()
            DataManager.sharedInstance.save()
            self.setTimerRestartState()
        } else {
            self.timer.isPaused = NSNumber(bool: true)
            self.timer.pauseTime = NSDate()
            DataManager.sharedInstance.save()
            self.setPausedTimerState()
        }
    }
    
    func onWarningsChange(slider: WarningSlider) {
        self.timer.addWarnings(slider.warningTimes)
        DataManager.sharedInstance.save()
        self.delegate?.shouldHideSetWarningPrompt(self)
    }
    
    // MARK: Public Methods
    
    func reset() {
        self.timer.canceled = 1
        DataManager.sharedInstance.save()
        self.invalidateTimersAndAlerts()
        self.delegate?.didResetTimer(self)
    }
    
    func invalidateTimersAndAlerts() {
        butterBarker?.stop()
        butterGrowler?.stop()
        nsTimerAlertInstance?.invalidate()
        nsTimerInstance?.invalidate()
    }

}

protocol TimerProgressDelegate {
    func didFinishTimer(sender: TimerProgressViewController)
    func didPauseTimer(sender: TimerProgressViewController)
    func didRestartTimer(sender: TimerProgressViewController)
    func didResetTimer(sender: TimerProgressViewController)
    func didFireWarning(sender: TimerProgressViewController)
    func shouldHideSetWarningPrompt(sender: TimerProgressViewController)
    func shouldShowSetWarningPrompt(sender: TimerProgressViewController)
}
