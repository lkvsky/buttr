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
    
    weak var slider: TimerProgressSlider!
    weak var warningSlider: WarningSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    func startTimer(duration: Int = 60, timeLeft: Int = 0, warnings: [Int]? = nil) {
        timerDuration = duration
        let slider = TimerProgressSlider(color: UIColor.primaryTextColor(), frame: self.bounds, maxTimeUnits: timerDuration)
        let warningSlider = WarningSlider(color: UIColor.primaryTextColor(), frame: self.bounds, maxTimeUnits: timerDuration)
        self.addSubview(slider)
        self.addSubview(warningSlider)
        self.slider = slider
        self.slider?.addTimeUnitByAmmount(timeLeft)
        self.warningSlider = warningSlider
        
        if let warningTimes = warnings {
            self.warningSlider.warningTimes = warningTimes
            self.warningSlider.numberOfWarnings = warningTimes.count
            self.warningSlider.warningAngles = [Int: Double]()
            
            for (index, warningTime) in enumerate(self.warningSlider.warningTimes) {
                let warningAngle: Double = 90.0 - (Double(self.timerDuration - warningTime) * Double(360.0) / Double(self.warningSlider.maxTimeUnits))
                self.warningSlider.warningAngles[index + 1] = warningAngle
            }
            
            self.warningSlider.setNeedsDisplay()
        }
    }
    
    func updateSlider() {
        slider?.addTimeUnitByAmmount(-1)
    }

}
