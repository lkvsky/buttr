//
//  HandleView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/21/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class HandleView: UIView {

    init(color: UIColor, frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = color
        self.layer.cornerRadius = self.frame.size.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func rectForHandle(circleCenter: CGPoint, radius: CGFloat, angleVal: Double = Config.BT_STARTING_ANGLE) -> CGRect {
        let handlePosition = MathHelpers.pointOnCircumference(angleVal, circleCenter: circleCenter, radius: radius)
        
        return CGRectMake(handlePosition.x, handlePosition.y, Config.BT_HANDLE_WIDTH, Config.BT_HANDLE_WIDTH)
    }
    
}
