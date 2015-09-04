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
    
    var buttrTailAnimationTimer: NSTimer!
    var buttrTongueAnimationTimer: NSTimer!
    var userHasDeniedNotifications: Bool = false
    var renderedNotificationWarningThisSession: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.containerView.backgroundColor = UIColor.backgroundColor()
        self.buttrCartoon.wagTail()
        
        // Listen for app to become active. If there's an active timer, render its progress. Otherwise
        // add the edit timer screen.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "launchTimerOrEditScreen", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // Listen for users who rejected notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDeniedNotifications", name: "UserDeniedNotifications", object: nil)
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
        
        if (self.userHasDeniedNotifications && !self.renderedNotificationWarningThisSession) {
            self.buttrCartoon.showNotificationDialogue()
            self.renderedNotificationWarningThisSession = true
        }
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
    
    @IBAction func onDoneTap(sender: UIButton) {
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            buttrCartoon.hideAlarmDialogue()
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
                }
        }
    }
    
    func userDeniedNotifications() {
        self.userHasDeniedNotifications = true
    }
    
    func animateButtrTail() {
        self.buttrCartoon.wagTail()
    }
    
    func animateButtrTongue() {
        self.buttrCartoon.stickOutTongue()
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
        // hide notification alert if rendered
        if (self.renderedNotificationWarningThisSession) {
            self.buttrCartoon.removeNotificationDialogue()
        }
        
        // instantiate timer object
        let timer = Timer(context: DataManager.sharedInstance.mainMoc)
        timer.duration = duration
        DataManager.sharedInstance.save()
        
        sender.timerControlView.animatedTransition()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.425 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] () -> Void in
            // remove edit timer vc
            sender.view.removeFromSuperview()
            sender.removeFromParentViewController()
            
            // start timer add timer progress vc
            timer.startTime = NSDate()
            DataManager.sharedInstance.save()
            self.addTimerProgressVC(timer)
        }
    }
    
    func didClearTimerValue(sender: EditTimerViewController) {
        self.animateButtrToZero()
    }
    
    func didGiveTimerValue(sender: EditTimerViewController) {
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
        }
    }
    
    func didFinishTimer(sender: TimerProgressViewController) {
        self.buttrCartoon.tiltHead(direction: -1)
        self.buttrCartoon.stickOutTongue()
        self.buttrCartoon.bark()
        
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

    }
    
    func didRestartTimer(sender: TimerProgressViewController) {
   
    }
    
    func didResetTimer(sender: TimerProgressViewController) {
        sender.view.removeFromSuperview()
        sender.removeFromParentViewController()
        self.addEditTimerVC()
        self.animateButtrToZero()
    }
    
    func didFireWarning(sender: TimerProgressViewController) {
        self.buttrCartoon.stickOutTongue()
        self.buttrCartoon.growl()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] () -> Void in
            self.buttrCartoon.hideAlarmDialogue()
        }
    }
    
    func shouldHideSetWarningPrompt(sender: TimerProgressViewController) {

    }
    
    func shouldShowSetWarningPrompt(sender: TimerProgressViewController) {

    }
}
