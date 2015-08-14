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
    
    var insertionContext: NSManagedObjectContext!
    var readingContext: NSManagedObjectContext!
    var deletionContext: NSManagedObjectContext!
    
    func setContexts(moc: NSManagedObjectContext) {
        self.insertionContext = moc
        self.readingContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        self.readingContext.parentContext = self.insertionContext
        self.deletionContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        self.deletionContext.parentContext = self.insertionContext
    }
    
    func save() {
        self.insertionContext.save(nil)
    }
}
