//
//  PawButton.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/12/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

@IBDesignable class PawButton: UIButton {
    
    weak var numberLabel: UILabel!
    
    override var tag: Int {
        didSet {
            self.numberLabel?.text = "\(self.tag)"
        }
    }
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                self.numberLabel?.textColor = UIColor.whiteColor()
            } else {
                self.numberLabel?.textColor = UIColor.primaryTextColor()
            }
        }
    }
    
    #if TARGET_INTERFACE_BUILDER
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        let numberLabel = UILabel(frame: CGRectMake(0, 35, self.frame.size.width, 20))
        numberLabel.textAlignment = .Center
        numberLabel.font = UIFont(name: "Lato", size: 20.0)
        numberLabel.textColor = UIColor.primaryTextColor()
        numberLabel.text = "\(self.tag)"
        self.addSubview(numberLabel)
        self.numberLabel = numberLabel
        self.setBackgroundImage(UIImage(named: "paw_print"), forState: .Normal)
    }
    
    #else
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let numberLabel = UILabel(frame: CGRectMake(0, 35, self.frame.size.width, 20))
        numberLabel.textAlignment = .Center
        numberLabel.font = UIFont(name: "Lato-Regular", size: 20.0)
        numberLabel.textColor = UIColor.primaryTextColor()
        numberLabel.text = "\(self.tag)"
        self.addSubview(numberLabel)
        self.numberLabel = numberLabel
        
        self.setBackgroundImage(UIImage(named: "paw_print"), forState: .Normal)
        self.setBackgroundImage(UIImage(named: "paw_print_filled"), forState: .Highlighted)
    }
    
    #endif
    
}
