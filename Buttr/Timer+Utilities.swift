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
        let duration = Double(self.duration)
        let timeLeftToTrack = Double(self.duration) + Double(self.startTime.timeIntervalSinceDate(self.pauseTime))
        self.startTime = NSDate(timeIntervalSinceNow: -NSTimeInterval(duration - timeLeftToTrack))
    }
    
    func projectedEndDate() -> NSDate {
        if (self.hasStarted()) {
            return self.startTime.dateByAddingTimeInterval(NSTimeInterval(self.duration))
        }
        
        return NSDate().dateByAddingTimeInterval(NSTimeInterval(self.duration))
    }
    
    func timeLeft() -> Int {
        let duration: Double = Double(self.duration)
        var elapsedTime: Double = 0
        
        
        if (self.isPaused.boolValue) {
            elapsedTime = Double(self.pauseTime.timeIntervalSinceDate(self.startTime))
        } else if (self.hasStarted()) {
            elapsedTime = Double(NSDate().timeIntervalSinceDate(self.startTime))
        }
    
        return Int(duration - elapsedTime)
    }
    
    func isActive() -> Bool {
        return self.hasStarted() && !self.canceled.boolValue
    }
    
    func hasStarted() -> Bool {
        if let _ = self.startTime {
            return true
        }
        
        return false
    }
    
    func isDone() -> Bool {
        return !self.isPaused.boolValue && !self.canceled.boolValue && self.projectedEndDate().timeIntervalSinceNow <= 0.0
    }
    
    func addWarnings(warningTimes: [Int]) {
        let times = warningTimes.map {
            (time) -> Warning in
        
            let warning = Warning(context: self.managedObjectContext!)
            warning.elapsedTime = NSNumber(integer: time)
            
            return warning
        }
        
        self.warnings = NSSet(array: times)
    }
    
    func getWarningsAsInts() -> [Int]? {
        var warningInts = [Int]()
        
        if (self.warnings.count > 0) {
            for warning in self.warnings {
                warningInts.append(Int(warning.elapsedTime))
            }
            
            return warningInts
        }
        
        return nil
    }
    
    // MARK: Class Methods
    
    class func getCurrentTimer() -> Timer? {
        let moc = DataManager.sharedInstance.mainMoc
        let entityDescription = NSEntityDescription.entityForName("Timer", inManagedObjectContext: moc)
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entityDescription
        
        if let results = try? moc.executeFetchRequest(fetchRequest) {
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
        
        if let results = try? moc.executeFetchRequest(fetchRequest) {
            for result in results {
                if let timer = result as? Timer {
                    if (!timer.isActive()) { moc.deleteObject(timer) }
                }
            }
            
            do {
                try moc.save()
            } catch _ {
            }
        }
    }
}
