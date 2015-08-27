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
    weak var timerControlButton: KeyPadControlButton!
    
    var delegate: TimerProgressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add subviews and setup properties
        self.addTimerProgressView()
        self.addTimerLabel()
        self.addTimerControlButton()
        self.view.sendSubviewToBack(self.timerLabelView)
        self.view.setNeedsUpdateConstraints()
        self.view.backgroundColor = UIColor.backgroundColor()

        // init actions and animation
        self.timeLeft = self.timer.timeLeft()
        self.timerProgressView.startTimer(duration: Int(self.timer.duration), timeLeft: self.timer.timeLeft(), warnings: self.timer.getWarningsAsInts())
        self.timerControlButton.addTarget(self, action: "toggleTimerState", forControlEvents: .TouchUpInside)
        self.timerProgressView.warningSlider.addTarget(self, action: "onWarningsChange:", forControlEvents: .ValueChanged)
        
        // start tracking timer
        if (self.timer.isPaused()) {
            self.setPausedTimerState()
        } else {
            nsTimerInstance = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: true)
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
        
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: frameWidth))
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 8.0))
        self.view.addConstraint(NSLayoutConstraint(item: timerProgressView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    }
    
    private func addTimerLabel() {
        let timerLabelView = TimerLabelView(frame: CGRectZero, fontSize: self.scaleDownViews() ? 30 : 40)
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
        
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: self.scaleDownViews() ? 93.3333 : 120))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: self.scaleDownViews() ? 35 : 45))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: timerControlButton, attribute: .Top, relatedBy: .Equal, toItem: timerProgressView, attribute: .Bottom, multiplier: 1.0, constant: 8))
    }
    
    func setPausedTimerState() {
        nsTimerInstance?.invalidate()
        timerIsPaused = true
        timerControlButton.standardBackgroundImage = UIImage(named: "start_button")
        self.delegate?.didPauseTimer(self)
    }
    
    func setTimerRestartState() {
        nsTimerInstance = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: true)
        timerIsPaused = false
        timerControlButton.standardBackgroundImage = UIImage(named: "pause_button")
        self.delegate?.didRestartTimer(self)
    }
    
    // MARK: Gestures and Events
    
    func timerFired() {
        if (timeLeft == 0) {
            self.fireTimerEndAlert()
            nsTimerInstance.invalidate()
            self.delegate?.didFinishTimer(self)
        } else {
            timeLeft = self.timer.timeLeft()
        }
    }
    
    func toggleTimerState() {
        if (timerIsPaused) {
            self.timer.resetStartTime()
            DataManager.sharedInstance.save()
            self.setTimerRestartState()
        } else {
            self.timer.pauseTime = NSDate()
            DataManager.sharedInstance.save()
            self.setPausedTimerState()
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
    func didFireWarning(sender: TimerProgressViewController)
}
