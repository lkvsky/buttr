//
//  Warning+Utilities.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/17/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import Foundation
import CoreData

extension Warning {
    // As seen from example here: http://www.jessesquires.com/swift-coredata-and-testing/
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Warning", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    // MARK: Instance methods
    
    func projectedFireDate() -> NSDate {
        return self.timer.startTime.dateByAddingTimeInterval(NSTimeInterval(self.elapsedTime.integerValue))
    }
    
    func alertMessage() -> String {
        let seconds = self.elapsedTime.integerValue % 60
        let minutes = (self.elapsedTime.integerValue / 60) % 60
        let hours = self.elapsedTime.integerValue / 3600
        
        if (hours > 0) {
            return String(format: "%02ld:%02ld:%02ld have passed.", arguments: [hours, minutes, seconds])
        } else if (minutes > 0) {
            return String(format: "%02ld:%02ld minutes have passed.", arguments: [minutes, seconds])
        } else {
            return "\(seconds) seconds have passed."
        }
    }
}
