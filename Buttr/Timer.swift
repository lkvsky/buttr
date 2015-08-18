//
//  Timer.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/17/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import Foundation
import CoreData

class Timer: NSManagedObject {

    @NSManaged var canceled: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var endTime: NSDate
    @NSManaged var pauseTime: NSDate
    @NSManaged var startTime: NSDate
    @NSManaged var warnings: NSSet

}
