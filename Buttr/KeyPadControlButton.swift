//
//  KeyPadControlButton.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/12/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit

@IBDesignable class KeyPadControlButton: UIButton {

    @IBInspectable var standardBackgroundImage: UIImage! {
        didSet {
            self.setBackgroundImage(standardBackgroundImage, forState: .Normal)
        }
    }
    
    @IBInspectable var highlightedBackgroundImage: UIImage! {
        didSet {
            self.setBackgroundImage(highlightedBackgroundImage, forState: .Highlighted)
        }
    }
    
    
    #if TARGET_INTERFACE_BUILDER
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        self.setBackgroundImage(standardBackgroundImage, forState: .Normal)
        self.setBackgroundImage(highlightedBackgroundImage, forState: .Highlighted)
    }
    
    #else
    
    override func awakeFromNib() {
        self.setBackgroundImage(standardBackgroundImage, forState: .Normal)
        self.setBackgroundImage(highlightedBackgroundImage, forState: .Highlighted)
    }
    
    #endif
}
