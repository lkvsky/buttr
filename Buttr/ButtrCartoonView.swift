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
    
    var headIsTilted: Bool = false
    
    // flag if buttr is already rolled over, crowched
    var inTransformativeState: Bool = false
    
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
        
        head.translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = false
        tail.translatesAutoresizingMaskIntoConstraints = false
        
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
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Leading, relatedBy: .Equal, toItem: body, attribute: .Trailing, multiplier: 1.0, constant: -20.0 * scale))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Bottom, relatedBy: .Equal, toItem: body, attribute: .Bottom, multiplier: 1.0, constant: -43.0 * scale))
    }
    
    private func addAlarmDialogue() {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView)
        self.alarmDialogue = imageView
        
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 79))
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 53))
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Leading, relatedBy: .Equal, toItem: head, attribute: .Trailing, multiplier: 1.0, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: alarmDialogue, attribute: .Top, relatedBy: .Equal, toItem: head, attribute: .Top, multiplier: 1.0, constant: 0))
        
        self.alarmDialogue.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    // MARK: Dialogue Box Methods
    
    private func showAlarmDialogue(image: UIImage) {
        self.alarmDialogue.image = image
        self.animateWithoutCompletion() {
            [unowned self] () -> Void in
            self.alarmDialogue.transform = CGAffineTransformIdentity
        }
    }
    
    func hideAlarmDialogue() {
        self.animateWithoutCompletion() {
            [unowned self] () -> Void in
            self.alarmDialogue.transform = CGAffineTransformMakeScale(0, 0)
        }
    }
    
    func growl() {
        self.showAlarmDialogue(UIImage(named: "grr_speech_bubble")!)
    }
    
    func bark() {
        self.showAlarmDialogue(UIImage(named: "bark_speech_bubble")!)
    }
    
    private func animateWithoutCompletion(block: (() -> ())) {
        UIView.animateWithDuration(0.125, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 12.0, options: [], animations: block, completion: nil)
    }
    
    // MARK: Animation Methods
    
    func wagTail() {
        UIView.animateWithDuration(0.1, delay: 0, options: .Autoreverse, animations: {
            [unowned self] () -> Void in
            let transform = CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(80))))
            self.tail.transform = CGAffineTransformTranslate(transform, 2, -2);
        }) {
            [unowned self](Bool finished) -> Void in
            self.tail.transform = CGAffineTransformIdentity
            
            UIView.animateWithDuration(0.125, delay: 0, options: .Autoreverse, animations: {
                [unowned self] () -> Void in
                let transform =  CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(80))))
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
    
    func closeEyes() {
        self.head.image = UIImage(named: "buttr_eyes_closed")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [unowned self] () -> Void in
            self.head.image = UIImage(named: "buttr_head")
        }
    }
    
    func crouch() {
        if (self.inTransformativeState) {
            return
        }
        
        self.headIsTilted = false
        self.inTransformativeState = true
        self.head.image = UIImage(named:"buttr_head_crouched")
        self.body.image = UIImage(named: "buttr_body_hunched")
        self.tail.layer.opacity = 0
        
        UIView.animateWithDuration(0.125, delay: 0, options: [], animations: {
            [unowned self] () -> Void in
            self.head.transform = CGAffineTransformMakeTranslation(0, 35)
            let bodyTranslation = CGAffineTransformMakeTranslation(0, -40)
            self.body.transform = CGAffineTransformScale(bodyTranslation, 1.7, 1.7)
            }) {
                [unowned self](Bool finished) -> Void in
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    [unowned self] () -> Void in
                    self.head.image = UIImage(named: "buttr_head")
                    self.body.image = UIImage(named: "buttr_body")
                    self.body.transform = CGAffineTransformIdentity
                    
                    UIView.animateWithDuration(0.125, delay: 0, options: [], animations: {
                        [unowned self] () -> Void in
                        self.head.transform = CGAffineTransformIdentity
                        self.tail.layer.opacity = 1
                        self.inTransformativeState = false
                    }, completion: nil)
                }
        }
    }
    
    func rollOver() {
        if (self.inTransformativeState) {
            return
        }
        
        self.headIsTilted = false
        self.inTransformativeState = true
        self.tail.layer.opacity = 0
        
        UIView.animateWithDuration(0.125, delay: 0, options: [], animations: {
            [unowned self] () -> Void in
            let translation = CGAffineTransformMakeTranslation(self.body.frame.width / 2, self.body.frame.height / 2)
            self.head.transform = CGAffineTransformRotate(translation, CGFloat(MathHelpers.DegreesToRadians(Double(130))))
            
            self.body.image = UIImage(named: "buttr_body_upside_down")
            let bodyTranslation = CGAffineTransformMakeTranslation(-10, -20)
            self.body.transform = CGAffineTransformScale(bodyTranslation, 2.2, 1.2)
            }) {
                [unowned self](Bool finished) -> Void in
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    [unowned self] () -> Void in
                    self.body.image = UIImage(named: "buttr_body")
                    self.body.transform = CGAffineTransformIdentity
                    
                    UIView.animateWithDuration(0.125, delay: 0, options: [], animations: {
                        [unowned self] () -> Void in
                        self.head.transform = CGAffineTransformIdentity
                        self.tail.layer.opacity = 1
                        self.inTransformativeState = false
                        }, completion: nil)
                }
        }
    }
    
    func respondToTouch() {
        let randomSelectorInt = Int(arc4random_uniform(4))
        
        switch randomSelectorInt {
        case 0:
            self.stickOutTongue()
            break
            
        case 1:
            self.crouch()
            break
            
        case 2:
            self.rollOver()
            break
            
        default:
            self.closeEyes()
            break
        }
    }
    
    func tiltHead(direction: Int = 1) {
        self.headIsTilted = true
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            let rotation = CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(direction * 22))))
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
