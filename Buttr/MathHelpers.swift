//
//  MathHelpers.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/8/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import Foundation
import UIKit

struct MathHelpers {
    static func DegreesToRadians (value: Double) -> Double {
        return value * M_PI / 180.0
    }
    
    static func RadiansToDegrees (value: Double) -> Double {
        return value * 180.0 / M_PI
    }
    
    static func Square (value: CGFloat) -> CGFloat {
        return value * value
    }
    
    static func pointOnCircumference(angleVal: Double, circleCenter: CGPoint, radius: CGFloat) -> CGPoint {
        var result: CGPoint = CGPointZero
        let y = round(Double(radius) * sin(MathHelpers.DegreesToRadians(-angleVal))) + Double(circleCenter.y)
        let x = round(Double(radius) * cos(MathHelpers.DegreesToRadians(-angleVal))) + Double(circleCenter.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
        
        return result
    }
    
    // Sourcecode from Apple example clockControl
    // Calculate the direction in degrees from a center point to an arbitrary position.
    static func AngleFromNorth(p1: CGPoint, p2: CGPoint, flipped: Bool) -> Double {
        var v: CGPoint  = CGPointMake(p2.x - p1.x, p2.y - p1.y)
        let vmag: CGFloat = Square(Square(v.x) + Square(v.y))
        var result: Double = 0.0
        
        v.x /= vmag;
        v.y /= vmag;
        
        let radians = Double(atan2(v.y,v.x))
        result = RadiansToDegrees(radians)
        
        return (result >= 0  ? result : result + 360.0);
    }
}