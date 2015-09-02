//
//  HomeViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, EditTimerDelegate, TimerProgressDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttrCartoon: ButtrCartoonView!
    @IBOutlet weak var resetButton: KeyPadControlButton!
    @IBOutlet weak var resetButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var setWarningPrompt: UIView!
    @IBOutlet weak var notificationWarning: UIButton!
    @IBOutlet weak var buttrCenter: NSLayoutConstraint!
    
    var buttrTailAnimationTimer: NSTimer!
    var buttrTongueAnimationTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.containerView.backgroundColor = UIColor.backgroundColor()
        self.resetButton.transform = CGAffineTransformMakeScale(0, 0)
        self.notificationWarning.transform = CGAffineTransformMakeScale(0, 0)
        self.buttrCartoon.wagTail()
        
        // hide render warning copy by default
        self.setWarningPrompt.transform = CGAffineTransformMakeScale(0, 0)
        
        // shift reset button
        if (self.scaleDownViews()) {
            self.resetButtonLeadingConstraint.constant = -15
        }
        
        // Listen for app to become active. If there's an active timer, render its progress. Otherwise
        // add the edit timer screen.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "launchTimerOrEditScreen", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // Listen for notification registration. Let the user know that if he or she declines to set notifications
        // then they will not receive an alert when the timer is finished
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDeniedNotifications:", name: "UserDeniedNotifications", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addEditTimerVC() {
        // add child edit timer view controller
        let editTimerVC = EditTimerViewController()
        self.addChildViewController(editTimerVC)
        editTimerVC.delegate = self
        
        // set proper sizing for view
        editTimerVC.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(editTimerVC.view)
        self.addChildVCConstraints(editTimerVC.view)
        
        editTimerVC.didMoveToParentViewController(self)
        
        // bring butter up front -- necessary for smaller screen sizes
        self.containerView.bringSubviewToFront(self.buttrCartoon)
        self.containerView.bringSubviewToFront(self.resetButton)
        
        // alert gets clipped by child view controller
        self.containerView.bringSubviewToFront(self.notificationWarning)
    }
    
    func addTimerProgressVC(timer: Timer) {
        // add child timer progress view controller
        let timerProgressVC = TimerProgressViewController()
        timerProgressVC.delegate = self
        timerProgressVC.timer = timer
        self.addChildViewController(timerProgressVC)
        
        // set proper sizing for view
        timerProgressVC.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(timerProgressVC.view)
        self.addChildVCConstraints(timerProgressVC.view)
        
        timerProgressVC.didMoveToParentViewController(self)
        
        // bring butter up front -- necessary for smaller screen sizes
        self.containerView.bringSubviewToFront(self.buttrCartoon)
        self.containerView.bringSubviewToFront(self.resetButton)
        
        // alert gets clipped by child view controller
        self.containerView.bringSubviewToFront(self.notificationWarning)
    }
    
    func addChildVCConstraints(childView: UIView) {
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .CenterX, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Top, multiplier: 1.0, constant: 50))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Width, relatedBy: .Equal, toItem: self.containerView, attribute: .Width, multiplier: 1.0, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Height, relatedBy: .Equal, toItem: self.containerView, attribute: .Width, multiplier: 1.1, constant: 0))
        
        childView.clipsToBounds = true;
        
        self.containerView.setNeedsLayout()
    }
    
    private func scaleDownViews() -> Bool {
        return self.view.frame.size.width <= 320
    }
    
    // MARK: Gestures and Events
    
    func launchTimerOrEditScreen() {
        // make sure container is in correct position
        self.containerView.transform = CGAffineTransformIdentity
        
        var editChildVc: EditTimerViewController? = self.childViewControllers.first as? EditTimerViewController
        var timer: Timer? = Timer.getCurrentTimer()
        
        if (nil == timer && nil != editChildVc) {
            // do nothing
        } else {
            for childVc in self.childViewControllers {
                if let view = childVc.view {
                    view?.removeFromSuperview()
                }
                
                childVc.removeFromParentViewController()
            }
            
            if (nil != timer) {
                self.addTimerProgressVC(timer!)
                self.animateButtrToActive()
            } else {
                self.addEditTimerVC()
                self.animateButtrToZero()
            }
        }
        
        self.buttrTailAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "animateButtrTail", userInfo: nil, repeats: true)
        self.buttrTongueAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(12.0, target: self, selector: "animateButtrTongue", userInfo: nil, repeats: true)
    }
    
    @IBAction func onResetTap(sender: UIButton) {
        if let editTimerVC = self.childViewControllers.first as? EditTimerViewController {
            editTimerVC.reset()
        }
        
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            timerProgressVC.reset()
            timerProgressVC.view.removeFromSuperview()
            timerProgressVC.removeFromParentViewController()
            self.addEditTimerVC()
        }
        
        self.animateButtrToZero()
        self.hideResetButton()
    }
    
    @IBAction func onDoneTap(sender: UIButton) {
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            // clear NSTimer instances and mark timer as complete
            timerProgressVC.reset()
            
            // remove timer vc
            timerProgressVC.view.removeFromSuperview()
            timerProgressVC.removeFromParentViewController()
            
            // add edit timer vc
            self.addEditTimerVC()
            
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 12.0,
                options: nil,
                animations: {
                    [unowned self]() -> Void in
                    // slide down container to hide done button
                    self.containerView.transform = CGAffineTransformIdentity
                }) {
                    [unowned self] (finished Bool) -> Void in
                    self.animateButtrToZero()
                    self.hideResetButton()
                    self.resetButton.standardBackgroundImage = UIImage(named: "reset_speech_bubble")
                    self.resetButton.enabled = true
                }
        }
    }
    
    func userDeniedNotifications(notification: NSNotification) {
        self.notificationWarning.addTarget(self, action: "dismissedNotificationAlert", forControlEvents: .TouchUpInside)
        self.buttrCenter.constant = -60

        UIView.animateWithDuration(0.3,
            delay: 0.125,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 12.0,
            options: nil,
            animations: {
                [unowned self]() -> Void in
                self.containerView.layoutIfNeeded()
                self.notificationWarning.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
    
    func dismissedNotificationAlert() {
        if (self.buttrCenter.constant != 0) {
            self.hideNotificationWarning()
        }
    }
    
    func animateButtrTail() {
        self.buttrCartoon.wagTail()
    }
    
    func animateButtrTongue() {
        self.buttrCartoon.stickOutTongue()
    }
    
    func hideResetButton (completion: ((Bool)->())? = nil) {
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.resetButton.transform = CGAffineTransformMakeScale(0, 0)
            }, completion: completion)
    }
    
    func showResetButton () {
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.resetButton.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }) {
                [unowned self] (Bool finished) -> Void in
                self.resetButton.transform = CGAffineTransformIdentity
        }
    }
    
    func hideNotificationWarning() {
        self.buttrCenter.constant = 0

        UIView.animateWithDuration(0.3,
            delay: 0.125,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 12.0,
            options: nil,
            animations: {
                [unowned self]() -> Void in
                self.containerView.layoutIfNeeded()
                self.notificationWarning.transform = CGAffineTransformMakeScale(0, 0)
            }, completion: nil)
    }
    
    func animateButtrToZero() {
        if (self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.straightenHead()
        }
    }
    
    func animateButtrToActive() {
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
        }
    }
    
    // MARK: Public Methods
    
    func prepareForAppClosure() {
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            timerProgressVC.invalidateTimersAndAlerts()
        }
        
        self.buttrTailAnimationTimer.invalidate()
        self.buttrTongueAnimationTimer.invalidate()
    }
    
    // MARK: Delegate Methods
    
    func didSetTimer(duration: Int, sender: EditTimerViewController) {
        // instantiate timer object
        let timer = Timer(context: DataManager.sharedInstance.mainMoc)
        timer.duration = duration
        DataManager.sharedInstance.save()
        
        sender.timerControlView.animatedTransition()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] () -> Void in
            // remove edit timer vc
            sender.view.removeFromSuperview()
            sender.removeFromParentViewController()
            
            // add timer progress vc
            self.addTimerProgressVC(timer)
        }
    }
    
    func didClearTimerValue(sender: EditTimerViewController) {
        self.animateButtrToZero()
        self.hideResetButton()
    }
    
    func didGiveTimerValue(sender: EditTimerViewController) {
        self.hideNotificationWarning()
        
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
            self.showResetButton()
        }
    }
    
    func didFinishTimer(sender: TimerProgressViewController) {
        self.buttrCartoon.tiltHead(direction: -1)
        self.buttrCartoon.stickOutTongue()
        self.resetButton.standardBackgroundImage = UIImage(named: "bark_speech_bubble")
        self.resetButton.enabled = false
        self.showResetButton()
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 12.0,
            options: nil,
            animations: {
                [unowned self]() -> Void in
                // slide up container to expose done button
                self.containerView.transform = CGAffineTransformMakeTranslation(0, -66.0)
            }, completion: nil)
    }
    
    func didPauseTimer(sender: TimerProgressViewController) {
        self.showResetButton()
    }
    
    func didRestartTimer(sender: TimerProgressViewController) {
        self.hideResetButton()
    }
    
    func didFireWarning(sender: TimerProgressViewController) {
        self.resetButton.standardBackgroundImage = UIImage(named: "grr_speech_bubble")
        self.resetButton.enabled = false
        self.showResetButton()
        self.buttrCartoon.stickOutTongue()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] () -> Void in
            self.hideResetButton() {
                [unowned self] (Bool finished) -> Void in
                self.resetButton.standardBackgroundImage = UIImage(named: "reset_speech_bubble")
                self.resetButton.enabled = true
            }
        }
    }
    
    func shouldHideSetWarningPrompt(sender: TimerProgressViewController) {
        UIView.animateWithDuration(0.3, animations: {
            [unowned self] () -> Void in
            self.setWarningPrompt.transform = CGAffineTransformMakeScale(0, 0)
        })
    }
    
    func shouldShowSetWarningPrompt(sender: TimerProgressViewController) {
        UIView.animateWithDuration(0.3, animations: {
            [unowned self] () -> Void in
            self.setWarningPrompt.transform = CGAffineTransformIdentity
        })
    }
}
