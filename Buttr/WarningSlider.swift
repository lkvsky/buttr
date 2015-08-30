//
//  WarningSlider.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/17/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class WarningSlider: CircularSlider {

    let warningIcon: UIImage = UIImage(named: "bone_warning")!
    var warningAngles: [Int: Double]!
    var warningTimes: [Int]!
    var numberOfWarnings: Int = 0
    var draggedWarningIndex: Int?
    
    // bound for range where time has passed, so don't allow warnings
    var maxAllowedAngle: Double = Config.BT_STARTING_ANGLE
    
    // TODO: Why can't I seem to write this as an override of circular slider's init?
    convenience init(color: UIColor, frame: CGRect, maxTimeUnits: Int = 60) {
        self.init(frame: frame)
        self.color = color
        self.maxTimeUnits = maxTimeUnits
    }

    // MARK: Drawing Methods
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        self.drawWarningAtAngle(ctx)
        
        if let warningPoints = self.warningAngles {
            for (index, angle) in warningPoints {
                if (index == self.draggedWarningIndex) {
                    self.drawWarningAtAngle(ctx, angleVal: angle, withLabel: false)
                } else {
                    self.drawWarningAtAngle(ctx, angleVal: angle, withLabel: true)
                }
            }
        }
        
        if let warningToBeSet = self.draggedWarningIndex {
            let centerYOffset: CGFloat = 30
            let centerWarningLabelText = "warning set"
            let centerWarningLabelSize = centerWarningLabelText.sizeWithAttributes([NSFontAttributeName: UIFont(name: "Bitter-Bold", size: 17.0)!])
            let centerWarningLabelStart = CGPointMake(self.center.x - (centerWarningLabelSize.width / 2), self.center.y + centerYOffset)
            
            let warningTimeText = self.getTextLabelForWarningAtAngle(self.warningAngles[warningToBeSet]!)
            let warnintTimeLabelSize = warningTimeText.sizeWithAttributes([NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17.0)!])
            let warningLabelStart = CGPointMake(self.center.x - (warnintTimeLabelSize.width / 2), self.center.y + centerYOffset + centerWarningLabelSize.height)
            
            centerWarningLabelText.drawAtPoint(centerWarningLabelStart, withAttributes: [
                NSFontAttributeName: UIFont(name: "Bitter-Bold", size: 17.0)!,
                NSForegroundColorAttributeName: self.color])
            warningTimeText.drawAtPoint(warningLabelStart, withAttributes: [
                NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17.0)!,
                NSForegroundColorAttributeName: self.color])
        }
    }
    
    func drawWarningAtAngle(ctx: CGContextRef, angleVal: Double = Config.BT_STARTING_ANGLE, withLabel: Bool = false) {
        CGContextSaveGState(ctx)
        
        let point = self.warningPointFromAngle(angleVal)
        warningIcon.drawAtPoint(point)
        
        if (withLabel) {
            let text = getTextLabelForWarningAtAngle(angleVal)
            let textPoint = self.pointForLabel(angleVal)
            text.drawAtPoint(textPoint, withAttributes: [
                NSFontAttributeName: UIFont(name: "Lato-Black", size: 12.0)!,
                NSForegroundColorAttributeName: self.color])
        }
        
        CGContextRestoreGState(ctx)
    }
    
    func getTextLabelForWarningAtAngle(angleVal: Double) -> NSString {
        let time = self.getTimeUnitFromAngleInt(angleVal)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = time / 3600
        var text: NSString!
        
        if (hours > 0) {
            text = NSString(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
        } else {
            text = NSString(format: "%02ld:%02ld", minutes, seconds)
        }
        
        return text
    }
    
    func pointForLabel(angleVal: Double) -> CGPoint {
        var result: CGPoint = CGPointZero
        var circleCenter = CGPointMake(self.frame.size.width/2.0 - self.warningIcon.size.height/2.0, self.frame.size.height/2.0 - self.warningIcon.size.height/2.0)
        let y = round(Double(radius - 1.3*self.warningIcon.size.width) * sin(MathHelpers.DegreesToRadians(-angleVal))) + Double(circleCenter.y)
        let x = round(Double(radius - 1.3*self.warningIcon.size.width) * cos(MathHelpers.DegreesToRadians(-angleVal))) + Double(circleCenter.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
        
        return result
    }
    
    // MARK: Drawing Helpers
    
    func warningPointFromAngle(angleVal: Double) -> CGPoint {
        let circleCenter = CGPointMake(self.frame.size.width/2.0 - self.warningIcon.size.height/2.0, self.frame.size.height/2.0 - self.warningIcon.size.height/2.0)
        
        return MathHelpers.pointOnCircumference(angleVal, circleCenter: circleCenter, radius: radius)
    }
    
    func rectForWarning(angleVal: Double = Config.BT_STARTING_ANGLE) -> CGRect {
        let origin = self.warningPointFromAngle(angleVal)
        
        return CGRectMake(origin.x, origin.y, self.warningIcon.size.width, self.warningIcon.size.height)
    }
    
    func warningAngleForPoint(point: CGPoint) -> Double {
        let centerPoint: CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        
        return 360.0 - MathHelpers.AngleFromNorth(centerPoint, p2: point, flipped: false)
    }
    
    func getAngleForMovingWarning(#startAngle: Double, updatedAngle: Double) -> Double {
        if (!self.isMovingClockwise(startAngle: startAngle, endAngle: updatedAngle) && (Config.BT_STARTING_ANGLE >= floor(startAngle) && Config.BT_STARTING_ANGLE < floor(updatedAngle) && abs(startAngle - updatedAngle) < 180 && startAngle != updatedAngle)) {
            return Config.BT_STARTING_ANGLE
        } else {
            return updatedAngle
        }
    }
    
    func timeForWarningAngle(angleVal: Double) -> Int {
        return self.maxTimeUnits - self.getTimeUnitFromAngleInt(angleVal)
    }
    
    func removeWarning(warningIndex: Int) {
        self.warningAngles.removeValueForKey(warningIndex)
        self.setNeedsDisplay()
    }
    
    // MARK: Interaction Detection
    
    func touchedChiefWarning(point: CGPoint) -> Bool {
        return CGRectContainsPoint(self.rectForWarning(), point)
    }
    
    // returns index for warning object that was touched, if any
    func chosenWarningIndex(point: CGPoint) -> Int? {
        if let warningAngles = self.warningAngles {
            for (index, angleVal) in warningAngles {
                if (CGRectContainsPoint(self.rectForWarning(angleVal: angleVal), point)) {
                    return index
                }
            }
        }
        
        return nil
    }
    
    func warningShouldBeRemoved(warningAngle: Double) -> Bool {
        let warningTime = self.getTimeUnitFromAngleInt(warningAngle)
        let timeLeft = self.getTimeUnitFromAngleInt(maxAllowedAngle)
        let warningIsAtZero = warningTime == 0
        
        // check if timer hasn't started yet
        if (maxAllowedAngle == Config.BT_STARTING_ANGLE) {
            return warningIsAtZero
        }
        
        // otherwise remove if warning has exceeded the time left, or is at zero
        return warningTime >= timeLeft || warningIsAtZero
    }
    
    func removeFiredWarnings() {
        if let warningPoints = self.warningAngles {
            for (index, angle) in warningPoints {
                if (self.warningShouldBeRemoved(angle)) {
                    self.removeWarning(index)
                }
            }
        }
        
        self.setNeedsDisplay()
    }
    
    // MARK: Gestures and Events
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        let touchPoint = touch.locationInView(self)
        
        // check if user is adding a new warning to the clock
        if (self.touchedChiefWarning(touchPoint)) {
            self.numberOfWarnings += 1
            
            if let warningPoints = self.warningAngles {
                self.warningAngles[self.numberOfWarnings] = self.warningAngleForPoint(touchPoint)
            } else {
                self.warningAngles = [self.numberOfWarnings: self.warningAngleForPoint(touchPoint)]
            }
            
            self.draggedWarningIndex = self.numberOfWarnings
            
            return true
        }
        
        // check if user is trying to move a specified warning
        if let warningIndex = self.chosenWarningIndex(touchPoint) {
            self.draggedWarningIndex = warningIndex
            
            return true;
        }
        
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        if let warningIndex = self.draggedWarningIndex {
            let startAngle = self.warningAngles[warningIndex]!
            let endAngle = self.warningAngleForPoint(touch.locationInView(self))
            
            self.warningAngles[warningIndex] = self.getAngleForMovingWarning(startAngle: startAngle, updatedAngle: endAngle)
        }
        
        self.setNeedsDisplay()
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        if let warningAngles = self.warningAngles {
            var warningTimes = [Int]()

            for (index, angle) in self.warningAngles {
                if (self.warningShouldBeRemoved(angle)) {
                    self.removeWarning(index)
                } else {
                    warningTimes.append(self.getTimeUnitFromAngleInt(angle))
                }
            }
            
            self.warningTimes = warningTimes
        }
        
        self.draggedWarningIndex = nil
        self.setNeedsDisplay()
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

}
