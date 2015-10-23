//
//  TimerActionView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 9/3/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class TimerActionView: UIView {
    
    var scaledDown: Bool = false
    
    weak var startButton: KeyPadControlButton!
    weak var resetButton: KeyPadControlButton!
    weak var pauseButton: KeyPadControlButton!
    weak var cancelButton: KeyPadControlButton!
    var cancelCenterConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, scaledDown: Bool = false, needsCancelButton: Bool = false) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        self.scaledDown = scaledDown
        self.addButtons(needsCancelButton: needsCancelButton)
        
        if (needsCancelButton) {
            self.showCancelButtonOnly()
        } else {
            self.showStartAndResetButtons()
        }
    }
    
    func addButtons(needsCancelButton needsCancelButton: Bool) {
        var cancel: KeyPadControlButton
        var pause: KeyPadControlButton
        var reset: KeyPadControlButton
        let start = KeyPadControlButton(frame: CGRectZero)
        start.standardBackgroundImage = UIImage(named: "start_button")
        self.addSubview(start)
        self.startButton = start

        var buttons: [KeyPadControlButton]

        if (needsCancelButton) {
            cancel = KeyPadControlButton(frame: CGRectZero)
            cancel.standardBackgroundImage = UIImage(named: "cancel_button")
            self.addSubview(cancel)
            self.cancelButton = cancel
            buttons = [start, cancel]
        } else {
            reset = KeyPadControlButton(frame: CGRectZero)
            pause = KeyPadControlButton(frame: CGRectZero)
            pause.standardBackgroundImage = UIImage(named: "pause_button")
            reset.standardBackgroundImage = UIImage(named: "reset_button")
            self.addSubview(reset)
            self.addSubview(pause)
            self.resetButton = reset
            self.pauseButton = pause
            buttons = [start, reset, pause]
        }
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 115))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 40))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        }
        
        if (needsCancelButton) {
            self.cancelCenterConstraint = NSLayoutConstraint(item: cancelButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
            self.addConstraint(self.cancelCenterConstraint)
            self.addConstraint(NSLayoutConstraint(item: startButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 80))
        } else {
            self.addConstraint(NSLayoutConstraint(item: startButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 80))
            self.addConstraint(NSLayoutConstraint(item: resetButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: -80))
            self.addConstraint(NSLayoutConstraint(item: pauseButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 80))
        }
    }
    
    func showCancelButtonOnly() {
        UIView.animateWithDuration(0.125, animations: { [unowned self] () -> Void in
            if (self.startButton.layer.opacity == 1) {
                self.startButton.layer.opacity = 0
                self.startButton.enabled = false
            }
            
            self.cancelCenterConstraint.constant = 0
        })
    }
    
    func showStartAndCancelButtons() {
        UIView.animateWithDuration(0.125, animations: { [unowned self] () -> Void in
            self.startButton.layer.opacity = 1
            self.startButton.enabled = true
            self.cancelCenterConstraint.constant = -80
        })
    }
    
    func showStartAndResetButtons() {
        // show start
        self.startButton.transform = CGAffineTransformIdentity
        self.startButton.layer.opacity = 1
        self.startButton.enabled = true
        
        // hide pause
        self.pauseButton.transform = CGAffineTransformMakeScale(0, 0)
        self.pauseButton.layer.opacity = 0
        self.pauseButton.enabled = false
    }
    
    func showPauseAndResetButtons() {
        // hide start
        self.startButton.transform = CGAffineTransformMakeScale(0, 0)
        self.startButton.layer.opacity = 0
        self.startButton.enabled = false
        
        // show pause
        self.pauseButton.transform = CGAffineTransformIdentity
        self.pauseButton.layer.opacity = 1
        self.pauseButton.enabled = true
    }
}
