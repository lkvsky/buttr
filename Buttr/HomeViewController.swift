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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var dialogue: UILabel!
    
    var buttrTailAnimationTimer: NSTimer!
    var buttrTongueAnimationTimer: NSTimer!
    var renderedNotificationWarningThisSession: Bool = false
    var renderedSetTimerDialogue: Bool = false
    var renderedDragBoneDialogue: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup done button
        self.doneButton.backgroundColor = UIColor.whiteColor()
        
        // setup dialogue
        self.dialogue.textColor = UIColor.primaryTextColor()
        self.dialogue.transform = CGAffineTransformMakeScale(0, 0)
        self.containerView.bringSubviewToFront(self.dialogue)
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.containerView.backgroundColor = UIColor.backgroundColor()
        self.buttrCartoon.wagTail()
        
        // Listen for app to become active. If there's an active timer, render its progress. Otherwise
        // add the edit timer screen.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "launchTimerOrEditScreen", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // check if the user has notifications turned off or is first load
        let userPrefs = NSUserDefaults.standardUserDefaults()
        let userHasRegisteredForNotifications: Bool = userPrefs.objectForKey("HasRegisteredNotifications") != nil
        let notificationSettingsOpt = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if let notificationSettings = notificationSettingsOpt {
            if (userHasRegisteredForNotifications && [] == notificationSettings.types) {
                self.userDeniedNotifications()
            }
        }
        
        
        // add tap gesture to buttr cartoon
        let tap = UITapGestureRecognizer(target: self, action: "onButtrCartoonTap:")
        self.buttrCartoon.addGestureRecognizer(tap)
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
        editTimerVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(editTimerVC.view)
        self.addChildVCConstraints(editTimerVC.view)
        
        editTimerVC.didMoveToParentViewController(self)
        
        // bring butter up front -- necessary for smaller screen sizes
        self.containerView.bringSubviewToFront(self.buttrCartoon)
    }
    
    func addTimerProgressVC(timer: Timer) {
        // add child timer progress view controller
        let timerProgressVC = TimerProgressViewController()
        timerProgressVC.delegate = self
        timerProgressVC.timer = timer
        self.addChildViewController(timerProgressVC)
        
        // set proper sizing for view
        timerProgressVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(timerProgressVC.view)
        self.addChildVCConstraints(timerProgressVC.view)
        
        timerProgressVC.didMoveToParentViewController(self)
        
        // bring butter up front -- necessary for smaller screen sizes
        self.containerView.bringSubviewToFront(self.buttrCartoon)
    }
    
    func addChildVCConstraints(childView: UIView) {
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .CenterX, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Top, multiplier: 1.0, constant: self.scaleDownViews() ? 15 : 40))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Width, relatedBy: .Equal, toItem: self.containerView, attribute: .Width, multiplier: 1.0, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Height, relatedBy: .Equal, toItem: self.containerView, attribute: .Height, multiplier: 1.0, constant: 0))
        
        childView.clipsToBounds = true;
        
        self.containerView.setNeedsLayout()
    }
    
    private func scaleDownViews() -> Bool {
        return self.view.frame.size.width <= 320
    }
    
    func showDialogue(message: String) {
        self.dialogue.text =  message
        self.dialogue.transform = CGAffineTransformIdentity
    }
    
    func hideDialogue() {
        self.dialogue.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    // MARK: Gestures and Events
    
    func launchTimerOrEditScreen() {
        // make sure container is in correct position
        self.containerView.transform = CGAffineTransformIdentity
        
        let editChildVc: EditTimerViewController? = self.childViewControllers.first as? EditTimerViewController
        let timer: Timer? = Timer.getCurrentTimer()
        
        if (nil == timer && nil != editChildVc) {
            // do nothing
        } else {
            for childVc in self.childViewControllers {
                if let view = childVc.view {
                    view.removeFromSuperview()
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
            // also calls delegate method which removes the timer progress
            // view and adds the edit timer view
            timerProgressVC.reset()
            
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 12.0,
                options: [],
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
        if (!self.renderedNotificationWarningThisSession) {
            self.showDialogue("Enable alerts to know when time's up!")
            self.renderedNotificationWarningThisSession = true
        }
    }
    
    func showSetTimerDialogue() {
        if (!self.renderedSetTimerDialogue) {
            self.showDialogue("Drag dots to set the timer!")
            self.renderedSetTimerDialogue = true
        }
    }
    
    func showSetWarningDialogue() {
        if (!self.renderedDragBoneDialogue) {
            self.showDialogue("Drag bones to set warnings!")
            self.renderedDragBoneDialogue = true
        }
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
        // hide any buttr notification/set timer dialogues
        self.hideDialogue()
        
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
    
    func onButtrCartoonTap(sender: UITapGestureRecognizer) {
        let touchPoint = sender.locationInView(self.buttrCartoon)
        let touchedHead = CGRectContainsPoint(self.buttrCartoon.head.bounds, self.buttrCartoon.convertPoint(touchPoint, toView: self.buttrCartoon.head))
        let touchedBody = CGRectContainsPoint(self.buttrCartoon.body.bounds, self.buttrCartoon.convertPoint(touchPoint, toView: self.buttrCartoon.body))
        
        if (touchedHead || touchedBody) {
            self.buttrCartoon.respondToTouch()
            
            if (self.renderedNotificationWarningThisSession) {
                self.hideDialogue()
            }
        }
    }
    
    func didClearTimerValue(sender: EditTimerViewController) {
        self.hideDialogue()
        self.animateButtrToZero()
    }
    
    func didGiveTimerValue(sender: EditTimerViewController) {
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
        }
    }
    
    func didFinishTimer(sender: TimerProgressViewController) {
        // prevent tapping butter from rendering dialogue boxes until
        // user has cancelled timer
        self.hideDialogue()
        self.buttrCartoon.tiltHead(-1)
        self.buttrCartoon.stickOutTongue()
        self.buttrCartoon.bark()
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 12.0,
            options: [],
            animations: {
                [unowned self]() -> Void in
                // slide up container to expose done button
                self.containerView.transform = CGAffineTransformMakeTranslation(0, -(self.doneButton.frame.size.height + 50))
            }, completion: nil)
    }
    
    func didPauseTimer(sender: TimerProgressViewController) {

    }
    
    func didRestartTimer(sender: TimerProgressViewController) {
   
    }
    
    func didResetTimer(sender: TimerProgressViewController) {
        sender.view.removeFromSuperview()
        sender.removeFromParentViewController()
        self.hideDialogue()
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
        self.hideDialogue()
        
        // check if this is user's first time setting warning
        // if so, render instructions for removing bone
        let userPrefs = NSUserDefaults.standardUserDefaults()
        let usersFirstTimeSettingWarning = userPrefs.objectForKey("UsersFirstTimeSettingWarning") == nil
        
        if (usersFirstTimeSettingWarning) {
            userPrefs.setObject(1, forKey: "UsersFirstTimeSettingWarning")
            userPrefs.synchronize()
            self.showDialogue("Remove warnings by dragging bones off the timeline!")
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                [unowned self] () -> Void in
                self.hideDialogue()
            }
        }
    }
    
    func shouldShowSetWarningPrompt(sender: TimerProgressViewController) {
        self.showDialogue("Drag bones to set warnings!")
    }
    
    func shouldRenderSetTimerDialogue(sender: EditTimerViewController) {
        self.showDialogue("Drag dots to set timer!")
    }

}
