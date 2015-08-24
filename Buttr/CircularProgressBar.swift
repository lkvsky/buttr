//
//  CircularProgressBar.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/21/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit
import QuartzCore

class CircularProgressBar: UIView {
    var animatedArcLayer: CAShapeLayer!
    var staticLayer: CAShapeLayer!
    weak var handleView: HandleView!
    
    var radius: CGFloat = 0
    var currentAngle: Double = Config.BT_STARTING_ANGLE
    var clockwise: Bool = true
    var drawTracks: Bool = false
    var color: UIColor!
    
    init(color: UIColor, frame: CGRect, clockwise: Bool = true, drawTracks: Bool = false) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        radius = (self.frame.size.width / 2) - Config.BT_SLIDER_PADDING
        self.clockwise = clockwise
        self.drawTracks = drawTracks
        self.color = color
        
        animatedArcLayer = CAShapeLayer()
        animatedArcLayer.bounds = self.bounds
        animatedArcLayer.position = self.center
        animatedArcLayer.fillColor = UIColor.clearColor().CGColor!
        animatedArcLayer.strokeColor = self.color.CGColor!
        animatedArcLayer.lineWidth = Config.BT_SLIDER_LINE_WIDTH
        self.layer.addSublayer(animatedArcLayer)
        
        staticLayer = CAShapeLayer()
        staticLayer.bounds = self.bounds
        staticLayer.position = self.center
        staticLayer.fillColor = UIColor.clearColor().CGColor!
        staticLayer.strokeColor = self.color.CGColor!
        staticLayer.lineWidth = Config.BT_SLIDER_LINE_WIDTH
        self.layer.addSublayer(staticLayer)
        
        let handleView = HandleView(color: color, frame: HandleView.rectForHandle(self.center, radius: radius))
        self.addSubview(handleView)
        self.handleView = handleView
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        if (self.drawTracks) {
            var ctx = UIGraphicsGetCurrentContext()
            CGContextSaveGState(ctx)
            
            self.color.set()
            
            for i in 0...59 {
                let circleCenter = CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0)
                let angleVal = Double(i) * 6.0
                let notchPoint: CGPoint = MathHelpers.pointOnCircumference(angleVal, circleCenter: circleCenter, radius: radius)
                let offset: CGFloat = Config.BT_HANDLE_WIDTH / 2 - 1.5
                
                CGContextFillEllipseInRect(ctx, CGRectMake(notchPoint.x + offset, notchPoint.y + offset, 3, 3))
            }
            
            CGContextRestoreGState(ctx)
        }
    }
    
    func shiftAngleByAmount(angleDifference: Double) -> Double {
        var endAngle = currentAngle
        
        if (currentAngle <= 90) {
            endAngle = currentAngle - angleDifference
        } else {
            endAngle = currentAngle + angleDifference
        }
        
        return endAngle
    }
    
    // Method for animation from timer edit to full view
    func animateToTimerProgress(endAngle: Double) {
        let originAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - Config.BT_STARTING_ANGLE)))
        let animationStartAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - currentAngle)))
        let animationEndAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - endAngle)))
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        // path for progress thus far
        let staticPath = UIBezierPath()
        staticPath.addArcWithCenter(center, radius: radius, startAngle: originAngle, endAngle: animationStartAngle, clockwise: self.clockwise)
        staticLayer.path = staticPath.CGPath
        
        // path for the animated porition of the progress
        let animationPath = UIBezierPath()
        animationPath.addArcWithCenter(center, radius: radius, startAngle: animationStartAngle, endAngle: animationEndAngle, clockwise: self.clockwise)
        animatedArcLayer.path = animationPath.CGPath
        
        // animation for the handle
        let handleAnimation = CAKeyframeAnimation(keyPath: "position")
        handleAnimation.path = animationPath.CGPath
        handleAnimation.duration = 0.3
        handleAnimation.repeatCount = 0
        handleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // animation for the progress line
        let arcAnimation = CABasicAnimation(keyPath: "strokeEnd")
        arcAnimation.fromValue = 0
        arcAnimation.toValue = 1
        arcAnimation.duration = 0.3
        arcAnimation.repeatCount = 0
        arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // add animations to necessary layers, update properties
        self.animatedArcLayer.addAnimation(arcAnimation, forKey: "arcAnimation")
        self.handleView.layer.addAnimation(handleAnimation, forKey: "handleAnimation")
        let newRect = HandleView.rectForHandle(CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0), radius: radius, angleVal: endAngle)
        self.handleView.center = CGPointMake(newRect.origin.x + self.handleView.frame.size.width / 2, newRect.origin.y + self.handleView.frame.size.width / 2)
        self.currentAngle = endAngle
    }
    
    // Method handling animation of timer in progress, backwards from the top
    func animatePath(endAngle: Double) {
        let originAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - Config.BT_STARTING_ANGLE)))
        let animationStartAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - currentAngle)))
        let animationEndAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - endAngle)))
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        // path for progress thus far
        let staticPath = UIBezierPath()
        staticPath.addArcWithCenter(center, radius: radius, startAngle: animationEndAngle, endAngle: originAngle, clockwise: false)
        staticLayer.path = staticPath.CGPath
        
        // path for the animated portion of the progress
        let animationPath = UIBezierPath()
        animationPath.addArcWithCenter(center, radius: radius, startAngle: animationEndAngle, endAngle: animationStartAngle, clockwise: true)
        animatedArcLayer.path = animationPath.CGPath
        
        // path for handle
        let handlePath = UIBezierPath()
        handlePath.addArcWithCenter(center, radius: radius, startAngle: animationStartAngle, endAngle: animationEndAngle, clockwise: false)
        
        // animation for the handle
        let handleAnimation = CAKeyframeAnimation(keyPath: "position")
        handleAnimation.path = handlePath.CGPath
        handleAnimation.duration = 0.3
        handleAnimation.repeatCount = 0
        handleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // animation for the progress line
        let arcAnimation = CABasicAnimation(keyPath: "strokeEnd")
        arcAnimation.fromValue = 1
        arcAnimation.toValue = 0
        arcAnimation.duration = 0.3
        arcAnimation.repeatCount = 0
        arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        arcAnimation.fillMode = kCAFillModeForwards
        arcAnimation.removedOnCompletion = false
        
        // add animations to necessary layers, update properties
        self.animatedArcLayer.addAnimation(arcAnimation, forKey: "arcAnimation")
        self.handleView.layer.addAnimation(handleAnimation, forKey: "handleAnimation")
        let newRect = HandleView.rectForHandle(CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0), radius: radius, angleVal: endAngle)
        self.handleView.center = CGPointMake(newRect.origin.x + self.handleView.frame.size.width / 2, newRect.origin.y + self.handleView.frame.size.width / 2)
        self.currentAngle = endAngle
    }
}
