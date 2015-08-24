//
//  TimerProgressSlider.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/12/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit
import QuartzCore

class TimerProgressSlider: CircularSlider {

    // MARK: Drawing Methods
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        self.drawPathToAngle(ctx)
        self.drawHandle(ctx)
    }

    // MARK: Gestures and Events
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        return false
    }

}
