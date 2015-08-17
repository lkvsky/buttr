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
    
    var animationTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.containerView.backgroundColor = UIColor.backgroundColor()
        self.addEditTimerVC()
        
        // kick off animations
        self.buttrCartoon.wagTail()
        self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "animateButtrTail", userInfo: nil, repeats: true)
        
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
        }
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
                },
                completion: nil)
        }
    }
    
    func animateButtrTail() {
        self.buttrCartoon.wagTail()
    }
    
    // MARK: Public Methods
    
    func prepareForAppClosure() {
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            timerProgressVC.reset()
            timerProgressVC.view.removeFromSuperview()
            timerProgressVC.removeFromParentViewController()
        }
        
        self.animationTimer.invalidate()
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
        if (self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.straightenHead()
        }
    }
    
    func didGiveTimerValue(sender: EditTimerViewController) {
        if (!self.buttrCartoon.headIsTilted) {
            self.buttrCartoon.tiltHead()
        }
    }
    
    func didFinishTimer(sender: TimerProgressViewController) {
        UIView.animateWithDuration(0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 12.0,
            options: nil,
            animations: {
                [unowned self]() -> Void in
                // slide up container to expose done button
                self.containerView.transform = CGAffineTransformMakeTranslation(0, -66.0)
            },
            completion: nil)
    }

}
