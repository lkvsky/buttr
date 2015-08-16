//
//  HomeViewController.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, EditTimerDelegate, TimerProgressDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundColor()
        self.addEditTimerVC()
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "launchTimerIfNecessary", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func addEditTimerVC() {
        // add child edit timer view controller
        let editTimerVC = EditTimerViewController.init(nibName: "EditTimerViewController", bundle: nil)
        self.addChildViewController(editTimerVC)
        editTimerVC.delegate = self
        
        // set proper sizing for view
        editTimerVC.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(editTimerVC.view)
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
        self.view.addSubview(timerProgressVC.view)
        self.addChildVCConstraints(timerProgressVC.view)
        
        timerProgressVC.didMoveToParentViewController(self)
    }
    
    func addChildVCConstraints(childView: UIView) {
        self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 367))
        self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 431))
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
    
    // MARK: Public Methods
    
    func prepareForAppClosure() {
        if let timerProgressVC = self.childViewControllers.first as? TimerProgressViewController {
            timerProgressVC.reset()
            timerProgressVC.view.removeFromSuperview()
            timerProgressVC.removeFromParentViewController()
        }
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
    
    func didFinishOrCancelTimer(sender: TimerProgressViewController) {
        // remove vc
        sender.view.removeFromSuperview()
        sender.removeFromParentViewController()
        
        // add edit timer vc
        self.addEditTimerVC()
    }

}
