//
//  DataManager.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/13/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let sharedInstance: DataManager = DataManager()
    
    var mainMoc: NSManagedObjectContext!
    
    func setContexts(moc: NSManagedObjectContext) {
        self.mainMoc = moc
    }
    
    func save() {
        self.mainMoc.save(nil)
    }
}
