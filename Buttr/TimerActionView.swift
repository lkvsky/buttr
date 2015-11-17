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
    weak var startButton: UIButton!
    weak var resetButton: UIButton!
    weak var pauseButton: UIButton!
    weak var cancelButton: UIButton!
    var cancelCenterConstraint: NSLayoutConstraint!
    var constraintConstant: CGFloat = 120
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, scaledDown: Bool = false, needsCancelButton: Bool = false) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        self.scaledDown = scaledDown
        self.constraintConstant = self.scaledDown ? 100 : 120
        self.addButtons(needsCancelButton: needsCancelButton)
        
        if (needsCancelButton) {
            self.showCancelButtonOnly()
        } else {
            self.showStartAndResetButtons()
        }
    }
    
    func addButtons(needsCancelButton needsCancelButton: Bool) {
        let buttonHeight = self.scaledDown ? 75 : 80
        var cancel: UIButton
        var pause: UIButton
        var reset: UIButton
        let start = UIButton(frame: CGRectZero)
        start.setTitle("START", forState: .Normal)
        start.setTitleColor(UIColor.whiteColor(), forState: .Normal)

        self.addSubview(start)
        self.startButton = start

        var buttons: [UIButton]

        if (needsCancelButton) {
            cancel = UIButton(frame: CGRectZero)
            cancel.setTitle("CANCEL", forState: .Normal)
            cancel.setTitleColor(UIColor.greige(), forState: .Normal)
            self.addSubview(cancel)
            self.cancelButton = cancel
            buttons = [start, cancel]
        } else {
            reset = UIButton(frame: CGRectZero)
            pause = UIButton(frame: CGRectZero)
            pause.setTitle("PAWS", forState: .Normal)
            pause.setTitleColor(UIColor.primaryTextColor(), forState: .Normal)
            reset.setTitle("RESET", forState: .Normal)
            reset.setTitleColor(UIColor.greige(), forState: .Normal)
            self.addSubview(reset)
            self.addSubview(pause)
            self.resetButton = reset
            self.pauseButton = pause
            buttons = [start, reset, pause]
        }
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: CGFloat(buttonHeight)))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: CGFloat(buttonHeight)))
            self.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
            
            if (button == start) {
                button.backgroundColor = UIColor.primaryTextColor()
            } else {
                button.backgroundColor = UIColor.whiteColor()
            }

            button.titleLabel?.font = UIFont(name: "Bitter-Regular", size: 18.0)
            button.layer.cornerRadius = CGFloat(buttonHeight / 2)
        }
        
        if (needsCancelButton) {
            self.cancelCenterConstraint = NSLayoutConstraint(item: cancelButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
            self.addConstraint(self.cancelCenterConstraint)
            self.addConstraint(NSLayoutConstraint(item: startButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: constraintConstant))
        } else {
            self.addConstraint(NSLayoutConstraint(item: startButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: constraintConstant))
            self.addConstraint(NSLayoutConstraint(item: resetButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: -constraintConstant))
            self.addConstraint(NSLayoutConstraint(item: pauseButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: constraintConstant))
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
            self.cancelCenterConstraint.constant = -self.constraintConstant
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
