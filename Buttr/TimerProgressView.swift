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
    
    var slider: CircularSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
    }
    
    func startTimer(duration: Int = 60) {
        timerDuration = duration
        let slider = CircularSlider(color: UIColor.primaryTextColor(), frame: self.bounds, maxTimeUnits: timerDuration, disabled: true)
        self.addSubview(slider)
        self.slider = slider
    }
    
    func updateSlider() {
        slider?.addTimeUnitByAmmount(1)
    }

}
