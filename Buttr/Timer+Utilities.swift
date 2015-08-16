//
//  Timer+Utilities.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/16/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import Foundation
import CoreData

extension Timer {
    // As seen from example here: http://www.jessesquires.com/swift-coredata-and-testing/
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    // MARK: Instance Methods
    
    func resetStartTime() {
        let durationInt = Int(self.duration)
        let timeLeftToTrack = Int(self.duration) + Int(self.startTime.timeIntervalSinceDate(self.pauseTime))
        self.startTime = NSDate(timeIntervalSinceNow: -NSTimeInterval(durationInt - timeLeftToTrack))
    }
    
    func projectedEndDate() -> NSDate {
        let date = self.startTime.dateByAddingTimeInterval(NSTimeInterval(self.duration))
        
        return date
    }
    
    func timeLeft() -> Int {
        return Int(self.duration) - Int(NSDate().timeIntervalSinceDate(self.startTime))
    }
    
    func isActive() -> Bool {
        return self.projectedEndDate().timeIntervalSinceNow > 0.0 && !self.canceled.boolValue
    }
    
    func isPaused() -> Bool {
        return self.pauseTime.timeIntervalSinceDate(self.startTime) > 0.0
    }
    
    // MARK: Class Methods
    
    class func getCurrentTimer() -> Timer? {
        let moc = DataManager.sharedInstance.mainMoc
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: moc)
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entityDescription
        
        if let results = moc.executeFetchRequest(fetchRequest, error: nil) {
            for result in results {
                if let timer = result as? Timer {
                    if (timer.isActive()) {
                        return timer
                    }
                }
            }
        }
        
        return nil
    }
    
    class func deleteInactiveTimers() {
        let moc = DataManager.sharedInstance.mainMoc
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: moc)
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entityDescription
        
        if let results = moc.executeFetchRequest(fetchRequest, error: nil) {
            for result in results {
                if let timer = result as? Timer {
                    if (!timer.isActive()) { moc.deleteObject(timer) }
                }
            }
            
            moc.save(nil)
        }
    }
}
