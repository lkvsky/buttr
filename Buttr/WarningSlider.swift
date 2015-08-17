//
//  WarningSlider.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/17/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class WarningSlider: CircularSlider {

    let warningIcon: UIImage = UIImage(named: "warning_icon")!
    var warningAngles: [Int: Double]!
    var warningTimes: [Int]!
    var numberOfWarnings: Int = 0
    
    // MARK: Drawing Methods
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        self.drawWarningAtAngle(ctx)
        
        if let warningPoints = self.warningAngles {
            for (index, angle) in warningPoints {
                self.drawWarningAtAngle(ctx, angleVal: angle, withLabel: true)
            }
        }
    }
    
    func drawWarningAtAngle(ctx: CGContextRef, angleVal: Double = Config.BT_STARTING_ANGLE, withLabel: Bool = false) {
        CGContextSaveGState(ctx)
        
        let point = self.warningPointFromAngle(angleVal)
        warningIcon.drawAtPoint(point)
        
        if (withLabel) {
            let time = self.timeForWarningAngle(angleVal)
            let seconds = time % 60
            let minutes = (time / 60) % 60
            let hours = time / 3600
            var text: NSString!
            
            if (hours > 0) {
                text = NSString(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
            } else {
                text = NSString(format: "%02ld:%02ld", minutes, seconds)
            }
            
            let textPoint = self.pointForLabel(angleVal)
            text.drawAtPoint(textPoint, withAttributes: [
                NSFontAttributeName: UIFont(name: "Lato-Black", size: 12.0)!,
                NSForegroundColorAttributeName: self.color])
        }
        
        CGContextRestoreGState(ctx)
    }
    
    func pointForLabel(angleVal: Double) -> CGPoint {
        var result: CGPoint = CGPointZero
        var circleCenter = CGPointMake(self.frame.size.width/2.0 - self.warningIcon.size.height/2.0, self.frame.size.height/2.0 - self.warningIcon.size.height/2.0)
        let y = round(Double(radius - 1.5*self.warningIcon.size.width) * sin(MathHelpers.DegreesToRadians(-angleVal))) + Double(circleCenter.y)
        let x = round(Double(radius - 1.5*self.warningIcon.size.width) * cos(MathHelpers.DegreesToRadians(-angleVal))) + Double(circleCenter.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
        
        return result
    }
    
    // MARK: Drawing Helpers
    
    func warningPointFromAngle(angleVal: Double) -> CGPoint {
        let circleCenter = CGPointMake(self.frame.size.width/2.0 - self.warningIcon.size.height/2.0, self.frame.size.height/2.0 - self.warningIcon.size.height/2.0)
        
        return self.pointOnCircumference(angleVal, circleCenter: circleCenter)
    }
    
    func rectForWarning(angleVal: Double = Config.BT_STARTING_ANGLE) -> CGRect {
        let origin = self.warningPointFromAngle(angleVal)
        
        return CGRectMake(origin.x, origin.y, self.warningIcon.size.width, self.warningIcon.size.height)
    }
    
    func warningAngleForPoint(point: CGPoint) -> Double {
        let centerPoint: CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        let currentAngle: Double = MathHelpers.AngleFromNorth(centerPoint, p2: point, flipped: false)
        
        return 360.0 - currentAngle
    }
    
    func timeForWarningAngle(angleVal: Double) -> Int {
        return self.maxTimeUnits - self.getTimeUnitFromAngleInt(angleVal)
    }
    
    // MARK: Gestures and Events
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        let touchPoint = touch.locationInView(self)
        
        if (CGRectContainsPoint(self.rectForWarning(), touchPoint)) {
            self.numberOfWarnings += 1
            
            if let warningPoints = self.warningAngles {
                self.warningAngles[self.numberOfWarnings] = self.warningAngleForPoint(touchPoint)
            } else {
                self.warningAngles = [self.numberOfWarnings: self.warningAngleForPoint(touchPoint)]
            }
            
            return true
        }
        
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        self.warningAngles[self.numberOfWarnings] = self.warningAngleForPoint(touch.locationInView(self))
        
        self.setNeedsDisplay()
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        var warningTimes = [Int]()
        
        for (index, angle) in self.warningAngles {
            warningTimes.append(self.timeForWarningAngle(angle))
        }
        
        self.warningTimes = warningTimes
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

}
