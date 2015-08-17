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
    
    var buttrTailAnimationTimer: NSTimer!
    var buttrTongueAnimationTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.containerView.backgroundColor = UIColor.backgroundColor()
        self.addEditTimerVC()
        self.resetButton.transform = CGAffineTransformMakeScale(0, 0)
        
        // kick off animations
        self.buttrCartoon.wagTail()
        self.buttrTailAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "animateButtrTail", userInfo: nil, repeats: true)
        self.buttrTongueAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(7.0, target: self, selector: "animateButtrTongue", userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "launchTimerIfNecessary", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func addEditTimerVC() {
        // add child edit timer view controller
        let editTimerVC = EditTimerViewController.init(nibName: "EditTimerViewController", bundle: nil)
        self.addChildViewController(editTimerVC)
        editTimerVC.delegate = self
        
        // set proper sizing for view
        editTimerVC.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(editTimerVC.view)
        self.addChildVCConstraints(editTimerVC.view)
        
        editTimerVC.didMoveToParentViewController(self)
    }
    
    func addTimerProgressVC(timer: Timer) {
        // add child timer progress view controller
        let timerProgressVC = TimerProgressViewController.init(nibName: "TimerProgressViewController", bundle: nil)
        timerProgressVC.delegate = self
        timerProgressVC.timer = timer
        self.addChildViewController(timerProgressVC)
        
        // set proper sizing for view
        timerProgressVC.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(timerProgressVC.view)
        self.addChildVCConstraints(timerProgressVC.view)
        
        timerProgressVC.didMoveToParentViewController(self)
    }
    
    func addChildVCConstraints(childView: UIView) {
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .CenterX, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: self.containerView, attribute: .Top, multiplier: 1.0, constant: 20))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 367))
        self.containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 431))
    }
    
    // MARK: Gestures and Events
    
    func launchTimerIfNecessary() {
        if let timer = Timer.getCurrentTimer() {
            if let childVc = self.childViewControllers.first as? EditTimerViewController {
                childVc.view.removeFromSuperview()
                childVc.removeFromParentViewController()
            }
            
            self.addTimerProgressVC(timer)
            self.animateButtrToActive()
        } else if let childVc = self.childViewControllers.first as? UIViewController {
            childVc.view.removeFromSuperview()
            childVc.removeFromParentViewController()
            
            self.addEditTimerVC()
            self.animateButtrToZero()
        } else {
            self.addEditTimerVC()
            self.animateButtrToZero()
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
                    self.resetButton.standardBackgroundImage = UIImage(named: "reset_speech_bubble")
                }
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
            
            UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
                [unowned self] () -> Void in
                self.resetButton.transform = CGAffineTransformMakeScale(0, 0)
                }, completion: nil)
        }
    }
    
    func animateButtrToActive() {
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
            
            UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
                [unowned self] () -> Void in
                self.resetButton.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    
    // MARK: Public Methods
    
    func prepareForAppClosure() {
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            timerProgressVC.invalidateTimersAndAlerts()
            timerProgressVC.view.removeFromSuperview()
            timerProgressVC.removeFromParentViewController()
        }
        
        self.buttrTailAnimationTimer.invalidate()
        self.buttrTongueAnimationTimer.invalidate()
    }
    
    // MARK: Delegate Methods
    
    func didSetTimer(duration: Int, sender: EditTimerViewController) {
        // instantiate timer object
        let timer = Timer(context: DataManager.sharedInstance.mainMoc)
        timer.duration = duration
        timer.startTime = NSDate()
        DataManager.sharedInstance.save()
        
        // remove edit timer vc
        sender.view.removeFromSuperview()
        sender.removeFromParentViewController()
        
        // add timer progress vc
        self.addTimerProgressVC(timer)
    }
    
    func didClearTimerValue(sender: EditTimerViewController) {
        self.animateButtrToZero()
    }
    
    func didGiveTimerValue(sender: EditTimerViewController) {
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
            
            UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
                [unowned self] () -> Void in
                    self.resetButton.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    
    func didFinishTimer(sender: TimerProgressViewController) {
        self.buttrCartoon.tiltHead(direction: -1)
        self.resetButton.standardBackgroundImage = UIImage(named: "bark_speech_bubble")
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 12.0,
            options: nil,
            animations: {
                [unowned self]() -> Void in
                // slide up container to expose done button
                self.containerView.transform = CGAffineTransformMakeTranslation(0, -66.0)
                self.resetButton.transform = CGAffineTransformMakeScale(1.1, 1.1)
                sender.view.transform = CGAffineTransformMakeScale(0, 0)
            }) {
                [unowned self] (finished Bool) -> Void in
                self.resetButton.transform = CGAffineTransformIdentity
            }
    }
}
