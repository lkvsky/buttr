//
//  ButtrCartoonView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class ButtrCartoonView: UIView {

    // permanent views
    weak var head: UIImageView!
    weak var body: UIImageView!
    weak var tail: UIImageView!
    weak var alarmDialogue: UIImageView!

    // conditional views
    weak var notifDialogueLeft: UIImageView!
    weak var notifDialogueRight: UIImageView!
    
    var headIsTilted: Bool = false
    
    override func awakeFromNib() {
        // initialize cartoon components
        let tailView = UIImageView(image: UIImage(named: "buttr_tail"))
        let bodyView = UIImageView(image: UIImage(named: "buttr_body"))
        let headView = UIImageView(image: UIImage(named: "buttr_head"))
        
        // add subviews
        self.addSubview(tailView)
        self.addSubview(bodyView)
        self.addSubview(headView)
        
        // store references
        head = headView
        body = bodyView
        tail = tailView
        
        // apply layout constraints
        self.applyConstraints()
        
        // set up alarm dialogue view
        self.addAlarmDialogue()
    }
    
    private func applyConstraints() {
        let scale: CGFloat = UIScreen.mainScreen().bounds.size.width <= 320 ? 0.8 : 1.0
        
        head.setTranslatesAutoresizingMaskIntoConstraints(false)
        body.setTranslatesAutoresizingMaskIntoConstraints(false)
        tail.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // head size constraints
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 139.0 * scale))
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .Height, relatedBy: .Equal, toItem: head, attribute: .Width, multiplier: 1.0, constant: -31.0 * scale))
        
        // body size constraints
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 98.0 * scale))
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .Height, relatedBy: .Equal, toItem: body, attribute: .Width, multiplier: 1.0, constant: 9.0 * scale))
        
        // tail size constraints
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 34.0 * scale))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Height, relatedBy: .Equal, toItem: tail, attribute: .Width, multiplier: 1.0, constant: 0))
        
        // alignment constraints
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .CenterX, relatedBy: .Equal, toItem: body, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .Bottom, relatedBy: .Equal, toItem: body, attribute: .Top, multiplier: 1.0, constant: 43.0 * scale))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Leading, relatedBy: .Equal, toItem: body, attribute: .Right, multiplier: 1.0, constant: -20.0 * scale))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Bottom, relatedBy: .Equal, toItem: body, attribute: .Bottom, multiplier: 1.0, constant: -43.0 * scale))
    }
    
    private func addAlarmDialogue() {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addSubview(imageView)
        self.alarmDialogue = imageView
        
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 79))
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 53))
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Leading, relatedBy: .Equal, toItem: head, attribute: .Right, multiplier: 1.0, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Top, relatedBy: .Equal, toItem: head, attribute: .Top, multiplier: 1.0, constant: 0))
        
        self.alarmDialogue.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    private func addNotifDialogueLeft() {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.image = UIImage(named: "notif_dialogue_left")
        
        self.addSubview(imageView)
        self.notifDialogueLeft = imageView
        self.notifDialogueLeft.layer.opacity = 0
        self.notifDialogueLeft.transform = CGAffineTransformMakeScale(0, 0)
        
        self.addConstraint(NSLayoutConstraint(item: notifDialogueLeft, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 86))
        self.addConstraint(NSLayoutConstraint(item: notifDialogueLeft, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 66))
        self.addConstraint(NSLayoutConstraint(item: notifDialogueLeft, attribute: .Trailing, relatedBy: .Equal, toItem: head, attribute: .Left, multiplier: 1.0, constant: -8))
        self.addConstraint(NSLayoutConstraint(item: notifDialogueLeft, attribute: .Top, relatedBy: .Equal, toItem: head, attribute: .Top, multiplier: 1.0, constant: 0))
    }
    
    private func addNotifDialogueRight() {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.image = UIImage(named: "notif_dialogue_right")
        
        self.addSubview(imageView)
        self.notifDialogueRight = imageView
        self.notifDialogueRight.layer.opacity = 0
        self.notifDialogueRight.transform = CGAffineTransformMakeScale(0, 0)
        
        self.addConstraint(NSLayoutConstraint(item: notifDialogueRight, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 86))
        self.addConstraint(NSLayoutConstraint(item: notifDialogueRight, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 104))
        self.addConstraint(NSLayoutConstraint(item: notifDialogueRight, attribute: .Leading, relatedBy: .Equal, toItem: head, attribute: .Right, multiplier: 1.0, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: notifDialogueRight, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    // MARK: Dialogue Box Methods
    
    private func showAlarmDialogue(image: UIImage) {
        self.alarmDialogue.image = image
        
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.alarmDialogue.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func hideAlarmDialogue() {
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.alarmDialogue.transform = CGAffineTransformMakeScale(0, 0)
            }, completion: nil)
    }
    
    func growl() {
        self.showAlarmDialogue(UIImage(named: "bark_speech_bubble")!)
    }
    
    func bark() {
        self.showAlarmDialogue(UIImage(named: "bark_speech_bubble")!)
    }
    
    func showNotificationDialogue() {
        self.addNotifDialogueLeft()
        self.addNotifDialogueRight()
        
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.notifDialogueRight.layer.opacity = 1
            self.notifDialogueRight.transform = CGAffineTransformIdentity
            self.notifDialogueLeft.layer.opacity = 1
            self.notifDialogueLeft.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    func removeNotificationDialogue() {
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: nil, animations: {
            [unowned self] () -> Void in
            self.notifDialogueRight.layer.opacity = 0
            self.notifDialogueRight.transform = CGAffineTransformMakeScale(0, 0)
            self.notifDialogueLeft.layer.opacity = 0
            self.notifDialogueLeft.transform = CGAffineTransformMakeScale(0, 0)
            }) {
                [unowned self] (Bool finished) -> Void in
                self.notifDialogueLeft.removeFromSuperview()
                self.notifDialogueRight.removeFromSuperview()
        }
    }
    
    // MARK: Animation Methods
    
    func wagTail() {
        UIView.animateWithDuration(0.1, delay: 0, options: .Autoreverse, animations: {
            [unowned self] () -> Void in
            var transform = CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(80))))
            self.tail.transform = CGAffineTransformTranslate(transform, 2, -2);
        }) {
            [unowned self](Bool finished) -> Void in
            self.tail.transform = CGAffineTransformIdentity
            
            UIView.animateWithDuration(0.125, delay: 0, options: .Autoreverse, animations: {
                [unowned self] () -> Void in
                var transform =  CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(80))))
                self.tail.transform = CGAffineTransformTranslate(transform, 2, -2);
                }) {
                    [unowned self](Bool finished) -> Void in
                    self.tail.transform = CGAffineTransformIdentity
            }
        }
    }
    
    func stickOutTongue() {
        self.head.image = UIImage(named: "buttr_head_tongue")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] () -> Void in
            self.head.image = UIImage(named: "buttr_head")
        }
    }
    
    func tiltHead(direction: Int = 1) {
        self.headIsTilted = true
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            var rotation = CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(direction * 22))))
            self.head.transform = CGAffineTransformTranslate(rotation, CGFloat(direction) * 5, 0)
        })
    }
    
    func straightenHead() {
        self.headIsTilted = false
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            self.head.transform = CGAffineTransformIdentity
        })
    }
}
