//
//  ButtrCartoonView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class ButtrCartoonView: UIView {

    weak var head: UIImageView!
    weak var body: UIImageView!
    weak var tail: UIImageView!
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
    }
    
    func applyConstraints() {
        head.setTranslatesAutoresizingMaskIntoConstraints(false)
        body.setTranslatesAutoresizingMaskIntoConstraints(false)
        tail.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // head size constraints
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 139.0))
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .Height, relatedBy: .Equal, toItem: head, attribute: .Width, multiplier: 1.0, constant: -31.0))
        
        // body size constraints
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 98.0))
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .Height, relatedBy: .Equal, toItem: body, attribute: .Width, multiplier: 1.0, constant: 9.0))
        
        // tail size constraints
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 34.0))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Height, relatedBy: .Equal, toItem: tail, attribute: .Width, multiplier: 1.0, constant: 0))
        
        // alignment constraints
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: body, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .CenterX, relatedBy: .Equal, toItem: body, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: head, attribute: .Bottom, relatedBy: .Equal, toItem: body, attribute: .Top, multiplier: 1.0, constant: 43.0))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Leading, relatedBy: .Equal, toItem: body, attribute: .Right, multiplier: 1.0, constant: -20.0))
        self.addConstraint(NSLayoutConstraint(item: tail, attribute: .Bottom, relatedBy: .Equal, toItem: body, attribute: .Bottom, multiplier: 1.0, constant: -43.0))
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
    
    func tiltHead() {
        self.headIsTilted = true
        UIView.animateWithDuration(0.125, animations: {
            [unowned self] () -> Void in
            var rotation = CGAffineTransformMakeRotation(CGFloat(MathHelpers.DegreesToRadians(Double(22))))
            self.head.transform = CGAffineTransformTranslate(rotation, 5, 0)
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
