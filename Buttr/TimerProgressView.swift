//
//  TimerProgressView.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/10/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

class TimerProgressView: UIView {

    var timerDuration: Int = 60
    
    var slider: TimerProgressSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
    }
    
    func startTimer(duration: Int = 60, timeLeft: Int = 0) {
        timerDuration = duration
        let slider = TimerProgressSlider(color: UIColor.primaryTextColor(), frame: self.bounds, maxTimeUnits: timerDuration)
        self.addSubview(slider)
        self.slider = slider
        self.slider?.addTimeUnitByAmmount(timeLeft)
    }
    
    func updateSlider() {
        slider?.addTimeUnitByAmmount(-1)
    }

}
