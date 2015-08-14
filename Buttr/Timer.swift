//
//  Timer.swift
//  Buttr
//
//  Created by Kyle Lucovsky on 8/13/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

import Foundation
import CoreData

class Timer: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var startTime: NSDate
    @NSManaged var pauseTime: NSDate
    @NSManaged var endTime: NSDate
    
    // As seen from example here: http://www.jessesquires.com/swift-coredata-and-testing/
    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
     }
    
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

    class func getCurrentTimer() -> Timer? {
        let moc = DataManager.sharedInstance.readingContext
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: moc)
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entityDescription
        
        if let results = moc.executeFetchRequest(fetchRequest, error: nil) {
            for result in results {
                if let timer = result as? Timer {
                    if (timer.projectedEndDate().timeIntervalSinceNow > 0.0) {
                        return timer
                    }
                }
            }
        }
        
        return nil
    }
    
    class func deleteTimers() {
        let moc = DataManager.sharedInstance.deletionContext
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: moc)
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entityDescription
        
        if let results = moc.executeFetchRequest(fetchRequest, error: nil) {
            for result in results {
                if let timer = result as? Timer {
                    moc.deleteObject(timer)
                }
            }
            
            moc.save(nil)
        }
    }
}
