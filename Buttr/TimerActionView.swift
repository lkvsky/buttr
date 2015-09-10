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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, scaledDown: Bool = false, initWithStartShowing: Bool = true) {
        super.init(frame: frame)
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        self.scaledDown = scaledDown
        self.addButtons()
        
        if (initWithStartShowing) {
            self.showStartAndResetButtons()
        } else {
            self.showPauseButton()
        }
    }
    
    func addButtons() {
        let start = KeyPadControlButton(frame: CGRectZero)
        let reset = KeyPadControlButton(frame: CGRectZero)
        let pause = KeyPadControlButton(frame: CGRectZero)
        
        start.standardBackgroundImage = UIImage(named: "start_button")
        pause.standardBackgroundImage = UIImage(named: "pause_button")
        reset.standardBackgroundImage = UIImage(named: "reset_button")
        
        for button in [start, reset, pause] {
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.addSubview(button)
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 115))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 40))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        }
        
        self.addConstraint(NSLayoutConstraint(item: start, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: -80))
        self.addConstraint(NSLayoutConstraint(item: reset, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 80))
        self.addConstraint(NSLayoutConstraint(item: pause, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        self.startButton = start
        self.resetButton = reset
        self.pauseButton = pause
    }
    
    func showStartAndResetButtons() {
        for button in [self.startButton, self.resetButton] {
            button.transform = CGAffineTransformIdentity
            button.layer.opacity = 1
            button.enabled = true
        }
        
        self.pauseButton.transform = CGAffineTransformMakeScale(0, 0)
        self.pauseButton.layer.opacity = 0
        self.pauseButton.enabled = false
    }
    
    func showPauseButton() {
        for button in [self.startButton, self.resetButton] {
            button.transform = CGAffineTransformMakeScale(0, 0)
            button.layer.opacity = 0
            button.enabled = false
        }
        
        self.pauseButton.transform = CGAffineTransformIdentity
        self.pauseButton.layer.opacity = 1
        self.pauseButton.enabled = true
    }
}
