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
    var clockwise: Bool = false
    var drawTracks: Bool = false
    var color: UIColor!
    
    init(color: UIColor, frame: CGRect, clockwise: Bool = false, drawTracks: Bool = false) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        radius = (self.frame.size.width / 2) - Config.BT_SLIDER_PADDING
        self.clockwise = clockwise
        self.drawTracks = drawTracks
        self.color = color
        
        // layer for the animated portion of the progress bar
        animatedArcLayer = CAShapeLayer()
        animatedArcLayer.bounds = self.bounds
        animatedArcLayer.position = self.center
        animatedArcLayer.fillColor = UIColor.clearColor().CGColor!
        animatedArcLayer.strokeColor = self.color.CGColor!
        animatedArcLayer.lineWidth = Config.BT_SLIDER_LINE_WIDTH
        self.layer.addSublayer(animatedArcLayer)
        
        // layer for the static portion of the progress bar
        staticLayer = CAShapeLayer()
        staticLayer.bounds = self.bounds
        staticLayer.position = self.center
        staticLayer.fillColor = UIColor.clearColor().CGColor!
        staticLayer.strokeColor = self.color.CGColor!
        staticLayer.lineWidth = Config.BT_SLIDER_LINE_WIDTH
        self.layer.addSublayer(staticLayer)
        
        // add progress bar handle
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
    
    // MARK: Drawing Helper Methods
    
    func shiftAngleByAmount(angleDifference: Double) -> Double {
        var endAngle = currentAngle
        
        if (currentAngle <= 90) {
            endAngle = currentAngle - angleDifference
        } else {
            endAngle = currentAngle + angleDifference
        }
        
        return endAngle
    }
    
    // abstraction method for generating arced bezier path
    func getArcedPath(#center: CGPoint, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) -> UIBezierPath {
        let staticPath = UIBezierPath()
        staticPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return staticPath
    }
    
    func getStrokeAnimation(#clockwise: Bool) -> CABasicAnimation {
        let arcAnimation = CABasicAnimation(keyPath: "strokeEnd")
        arcAnimation.duration = 0.3
        arcAnimation.repeatCount = 0
        arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        if (clockwise) {
            arcAnimation.fromValue = 0
            arcAnimation.toValue = 1
        } else {
            arcAnimation.fromValue = 1
            arcAnimation.toValue = 0
            arcAnimation.fillMode = kCAFillModeForwards
            arcAnimation.removedOnCompletion = false
        }
        
        return arcAnimation
    }
    
    func getHandleAnimationObject() -> CAKeyframeAnimation {
        let handleAnimation = CAKeyframeAnimation(keyPath: "position")
        handleAnimation.duration = 0.3
        handleAnimation.repeatCount = 0
        handleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return handleAnimation
    }
    
    // MARK: Public Methods
    
    func animateProgressBar(#endAngle: Double) {
        let originAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - Config.BT_STARTING_ANGLE)))
        let animationStartAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - currentAngle)))
        let animationEndAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - endAngle)))
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        var staticPath, animationPath, handlePath: UIBezierPath
        
        if (clockwise) {
            staticPath = self.getArcedPath(center: center, startAngle: originAngle, endAngle: animationStartAngle, clockwise: true)
            animationPath = self.getArcedPath(center: center, startAngle: animationStartAngle, endAngle: animationEndAngle, clockwise: true)
            handlePath = animationPath
        } else {
            staticPath = self.getArcedPath(center: center, startAngle: animationEndAngle, endAngle: originAngle, clockwise: false)
            animationPath = self.getArcedPath(center: center, startAngle: animationEndAngle, endAngle: animationStartAngle, clockwise: true)
            handlePath = self.getArcedPath(center: center, startAngle: animationStartAngle, endAngle: animationEndAngle, clockwise: false)
        }
        
        // path for progress thus far
        staticLayer.path = staticPath.CGPath
        
        // path for the animated porition of the progress
        animatedArcLayer.path = animationPath.CGPath
        
        // animation for the handle
        let handleAnimation = self.getHandleAnimationObject()
        handleAnimation.path = handlePath.CGPath
        
        // animation for the progress line
        let arcAnimation = self.getStrokeAnimation(clockwise: clockwise)
        
        // add animations to necessary layers, update properties
        self.animatedArcLayer.addAnimation(arcAnimation, forKey: "arcAnimation")
        self.handleView.layer.addAnimation(handleAnimation, forKey: "handleAnimation")
        let newRect = HandleView.rectForHandle(CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0), radius: radius, angleVal: endAngle)
        self.handleView.center = CGPointMake(newRect.origin.x + self.handleView.frame.size.width / 2, newRect.origin.y + self.handleView.frame.size.width / 2)
        self.currentAngle = endAngle
    }
}
