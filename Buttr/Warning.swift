//
//  Warning.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/17/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import Foundation
import CoreData

class Warning: NSManagedObject {

    @NSManaged var elapsedTime: NSNumber
    @NSManaged var timer: Timer

}
