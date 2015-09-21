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
    weak var warningSlider: WarningSlider!
    weak var circularProgressBar: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Public Methods
    
    func setupTimerProgressView(duration: Int = 60, timeLeft: Int = 0, warnings: [Int]? = nil) {
        timerDuration = duration
        
        // add circular progress bar
        let circularProgressBar = CircularProgressBar(color: UIColor.primaryTextColor(), frame: self.bounds, clockwise: false)
        self.addSubview(circularProgressBar)
        self.circularProgressBar = circularProgressBar
        self.updateProgressBar(Double(timeLeft))
        
        // add warning slider
        let warningSlider = WarningSlider(color: UIColor.warningTextColor(), frame: self.bounds, maxTimeUnits: timerDuration)
        warningSlider.maxAllowedAngle = 360.0 + self.circularProgressBar.currentAngle
        self.addSubview(warningSlider)
        self.warningSlider = warningSlider

        if let warningTimes = warnings {
            self.warningSlider.warningTimes = warningTimes
            self.warningSlider.numberOfWarnings = warningTimes.count
            self.warningSlider.warningAngles = [Int: Double]()
            
            for (index, warningTime) in self.warningSlider.warningTimes.enumerate() {
                let warningAngle: Double = 90.0 - (Double(warningTime) * Double(360.0) / Double(self.warningSlider.maxTimeUnits))
                let warningIndex: Int = index + 1
                
                if (!warningSlider.warningShouldBeRemoved(warningIndex, warningAngle: warningAngle)) {
                    self.warningSlider.warningAngles[warningIndex] = warningAngle
                }
            }
            
            self.warningSlider.setNeedsDisplay()
        }
    }

    func updateProgressBar(elapsedTime: Double = -1) {
        let angleDifference = elapsedTime * Double(360.0) / Double(timerDuration)
        let newAngle = circularProgressBar?.shiftAngleByAmount(angleDifference)
        
        circularProgressBar?.animateProgressBar(endAngle: newAngle!)
        warningSlider?.maxAllowedAngle = 360.0 + newAngle!
    }
}
