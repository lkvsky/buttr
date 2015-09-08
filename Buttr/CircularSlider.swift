//
//  CircularSlider.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/6/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

// MARK: Slider Config

struct Config {
    static let BT_SLIDER_LINE_WIDTH: CGFloat = 5.0
    static let BT_SLIDER_PADDING: CGFloat = 15.0
    static let BT_HANDLE_WIDTH: CGFloat = 20.0
    static let BT_STARTING_ANGLE: Double = 90.0
    static let BT_TOUCH_AREA: CGFloat = 30.0
}

class CircularSlider: UIControl, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    // radius of the slider
    var radius: CGFloat = 0
    
    // current angle of the slider
    var angle: Double = Config.BT_STARTING_ANGLE
    
    // color of the slider path/handle
    var color: UIColor = UIColor.blackColor()
    
    // this property may represent number of minutes and hours,
    // but most often is seconds
    var maxTimeUnits: Int = 60
    
    // flag to prevent slider from moving backwards total value is 0
    var canMoveBackwards: Bool = false
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        radius = (self.frame.size.width / 2) - Config.BT_SLIDER_PADDING
    }
    
    convenience init(color: UIColor, frame: CGRect, maxTimeUnits: Int = 60) {
        self.init(frame: frame)
        self.color = color
        self.maxTimeUnits = maxTimeUnits
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Drawing Methods
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        self.drawBackground(ctx)
        self.drawPathToAngle(ctx)
        self.drawHandle(ctx)
    }
    
    func drawHandle(ctx: CGContextRef) {
        CGContextSaveGState(ctx)
        
        self.color.set()
        CGContextFillEllipseInRect(ctx, HandleView.rectForHandle(CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0), radius: radius, angleVal: angle))
        
        CGContextRestoreGState(ctx)
    }
    
    func drawBackground(ctx: CGContextRef) {
        CGContextSaveGState(ctx)
        
        self.color.set()
        
        for i in 0...(maxTimeUnits) {
            let notchPoint: CGPoint = self.handlePointFromAngle(Double(i) * Double(360 / maxTimeUnits));
            let offset: CGFloat = Config.BT_HANDLE_WIDTH / 2 - 1.5
            
            CGContextFillEllipseInRect(ctx, CGRectMake(notchPoint.x + offset, notchPoint.y + offset, 3, 3))
        }
        
        CGContextRestoreGState(ctx)
    }
    
    func drawPathToAngle(ctx: CGContextRef) {
        CGContextSaveGState(ctx)
        
        let startingAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - Config.BT_STARTING_ANGLE)))
        let endingAngle: CGFloat = CGFloat(MathHelpers.DegreesToRadians(Double(360 - angle)))
        
        CGContextAddArc(ctx, CGFloat(self.frame.size.width / 2.0), CGFloat(self.frame.size.height / 2.0), radius, startingAngle, endingAngle, 0)
        self.color.set()
        CGContextSetLineWidth(ctx, Config.BT_SLIDER_LINE_WIDTH)
        CGContextSetLineCap(ctx, kCGLineCapRound)
        CGContextDrawPath(ctx, kCGPathStroke)
        
        CGContextRestoreGState(ctx)
    }
    
    // MARK: Helper Methods
    
    func handlePointFromAngle(angleVal: Double) -> CGPoint {
        let circleCenter = CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0)
        
        return MathHelpers.pointOnCircumference(angleVal, circleCenter: circleCenter, radius: radius)
    }
    
    func moveHandle(point: CGPoint, ignoreDirection: Bool = false) {
        let centerPoint: CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        let startAngle: Double = angle
        let updatedAngle: Double = 360.0 - MathHelpers.AngleFromNorth(centerPoint, p2: point, flipped: false)
        
        // flags to detect if we need to increase or decrease time
        let userIsTryingToMoveBackwards: Bool = !self.isMovingClockwise(startAngle: startAngle, endAngle: updatedAngle) && (Config.BT_STARTING_ANGLE >= floor(startAngle) && Config.BT_STARTING_ANGLE < floor(updatedAngle) && abs(angle - updatedAngle) < 180 && startAngle != updatedAngle)
        let userCompletedRevolution: Bool = self.isMovingClockwise(startAngle: angle, endAngle: updatedAngle) && (Config.BT_STARTING_ANGLE < floor(angle) && Config.BT_STARTING_ANGLE >= floor(updatedAngle) && abs(angle - updatedAngle) < 100)
        let userCompletedBackwardRevolution: Bool = !self.isMovingClockwise(startAngle: angle, endAngle: updatedAngle) && (Config.BT_STARTING_ANGLE < floor(updatedAngle) && Config.BT_STARTING_ANGLE >= floor(angle) && abs(angle - updatedAngle) < 100)
        
        if (userIsTryingToMoveBackwards && !ignoreDirection && !self.canMoveBackwards) {
            angle = Config.BT_STARTING_ANGLE
        } else {
            angle = updatedAngle
        }
    
        if (userCompletedRevolution || userCompletedBackwardRevolution) {
            let direction = userCompletedRevolution ? 1 : -1;
            NSNotificationCenter.defaultCenter().postNotificationName("UserPassedStartingAngle", object: self, userInfo: ["direction": direction])
        }
        
        setNeedsDisplay()
    }
    
    func touchedSliderPath(point: CGPoint) -> Bool {
        let centerPoint: CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        let currentAngle: Double = MathHelpers.AngleFromNorth(centerPoint, p2: point, flipped: false);
        let proposedPoint = self.handlePointFromAngle(360.0 - currentAngle)
        let proposedSliderRect = CGRectMake(proposedPoint.x - (1/3 * Config.BT_HANDLE_WIDTH), proposedPoint.y - (1/3 * Config.BT_HANDLE_WIDTH), Config.BT_TOUCH_AREA, Config.BT_TOUCH_AREA)
        
        return CGRectContainsPoint(proposedSliderRect, point)
    }
    
    func getTimeUnitFromAngleInt(angleInt: Double) -> Int {
        if (Int(angleInt) == Int(Config.BT_STARTING_ANGLE)) {
            return 0
        } else {
            let timeToAngleRatio = 360.0 / Double(maxTimeUnits)
            let angleLessThan90Degrees = Double(angleInt) < Config.BT_STARTING_ANGLE
            let valueIfAngleIsLessThan90 = Double(angleInt) / timeToAngleRatio + (Double(maxTimeUnits) * 3.0 / 4.0)
            let valueIfAngleIsGreaterThan90 = (Double(angleInt) / timeToAngleRatio) - (Double(maxTimeUnits) / 4.0)
            let timeUnit = Int(Double(maxTimeUnits) - (angleLessThan90Degrees ? valueIfAngleIsLessThan90 : valueIfAngleIsGreaterThan90))
            
            return timeUnit
        }
    }
    
    func addTimeUnitByAmmount(timeInt: Int) {
        let angleDifference = Double(timeInt) * Double(360.0) / Double(maxTimeUnits)
        
        if (angle <= Config.BT_STARTING_ANGLE) {
            angle -= angleDifference
        } else {
            angle += angleDifference
        }

        self.setNeedsDisplay()
    }
    
    func isMovingClockwise(#startAngle: Double, endAngle: Double) -> Bool {
        return endAngle < startAngle || (floor(startAngle) <= 10 && floor(endAngle) >= 350)
    }
    
    // MARK: Gestures & Events
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)

        return self.touchedSliderPath(touch.locationInView(self))
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        self.moveHandle(touch.locationInView(self))
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        return true
    }

}
