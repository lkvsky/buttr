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
    static let BT_STARTING_ANGLE: Int = 90
}

class CircularSlider: UIControl {
    
    // MARK: Properties
    
    // radius of the slider
    var radius: CGFloat = 0
    
    // current angle of the slider
    var angle: Int = Config.BT_STARTING_ANGLE
    
    // color of the slider path/handle
    var color: UIColor = UIColor.blackColor()
    
    // this property may represent number of minutes and hours,
    // but most often is seconds
    var maxTimeUnits: Int = 60
    
    // If true, disables the user from pulling the handle
    var disabled: Bool = false
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        radius = (self.frame.size.width / 2) - Config.BT_SLIDER_PADDING
    }
    
    convenience init(color: UIColor, frame: CGRect, maxTimeUnits: Int = 60, disabled: Bool = false) {
        self.init(frame: frame)
        self.color = color
        self.maxTimeUnits = maxTimeUnits
        self.disabled = disabled
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
        CGContextFillEllipseInRect(ctx, self.rectForHandle())
        
        CGContextRestoreGState(ctx)
    }
    
    func drawBackground(ctx: CGContextRef) {
        CGContextSaveGState(ctx)
        
        self.color.set()
        
        for i in 0...59 {
            let notchPoint: CGPoint = self.handlePointFromAngle((i * 6));
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
        CGContextSetLineCap(ctx, kCGLineCapButt)
        CGContextDrawPath(ctx, kCGPathStroke)
        
        CGContextRestoreGState(ctx)
    }
    
    // MARK: Helper Methods
    
    func pointOnCircumference(angleInt: Int, circleCenter: CGPoint) -> CGPoint {
        var result: CGPoint = CGPointZero
        let y = round(Double(radius) * sin(MathHelpers.DegreesToRadians(Double(-angleInt)))) + Double(circleCenter.y)
        let x = round(Double(radius) * cos(MathHelpers.DegreesToRadians(Double(-angleInt)))) + Double(circleCenter.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
        
        return result
    }
    
    func handlePointFromAngle(angleInt: Int) -> CGPoint {
        let circleCenter = CGPointMake(self.frame.size.width/2.0 - Config.BT_HANDLE_WIDTH/2.0, self.frame.size.height/2.0 - Config.BT_HANDLE_WIDTH/2.0)
        
        return self.pointOnCircumference(angleInt, circleCenter: circleCenter)
    }
    
    func rectForHandle() -> CGRect {
        var handlePosition = handlePointFromAngle(angle)
        
        return CGRectMake(handlePosition.x, handlePosition.y, Config.BT_HANDLE_WIDTH, Config.BT_HANDLE_WIDTH)
    }
    
    func moveHandle(point: CGPoint) {
        let centerPoint: CGPoint  = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        let currentAngle: Double = MathHelpers.AngleFromNorth(centerPoint, p2: point, flipped: false);
        let angleInt = Int(floor(currentAngle))
        
        angle = Int(360 - angleInt)
        setNeedsDisplay()
    }
    
    func getTimeUnitFromAngleInt(angleInt: Int) -> Int {
        let timeToAngleRatio = 360.0 / Double(maxTimeUnits)
        let angleLessThan90Degrees = Double(angleInt) <= 90.0
        let valueIfAngleIsLessThan90 = Double(angleInt) / timeToAngleRatio + (Double(maxTimeUnits) * 3.0 / 4.0)
        let valueIfAngleIsGreaterThan90 = (Double(angleInt) / timeToAngleRatio) - (Double(maxTimeUnits) / 4.0)
        let timeUnit = Int(Double(maxTimeUnits) - (angleLessThan90Degrees ? valueIfAngleIsLessThan90 : valueIfAngleIsGreaterThan90))
        
        return timeUnit
    }
    
    func addTimeUnitByAmmount(timeInt: Int) {
        let angleDifference = Int(round(Double(timeInt) * Double(360.0) / Double(maxTimeUnits)))
        
        if (angle <= 90) {
            angle -= angleDifference
        } else {
            angle += angleDifference
        }

        self.setNeedsDisplay()
    }
    
    // MARK: Gestures & Events
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        if (disabled) { return false }
        
        return CGRectContainsPoint(self.rectForHandle(), touch.locationInView(self))
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        let lastPoint = touch.locationInView(self)
        self.moveHandle(lastPoint)
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        return true
    }

}
