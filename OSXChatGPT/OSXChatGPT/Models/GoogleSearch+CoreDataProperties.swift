//
//  GoogleSearch+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/28.
//
//

import Foundation
import CoreData


extension GoogleSearch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoogleSearch> {
        return NSFetchRequest<GoogleSearch>(entityName: "GoogleSearch")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var maxSearchResult: Int16
    @NSManaged public var dateRestrict: Int16
    @NSManaged public var result: NSOrderedSet?
    @NSManaged public var search: String?
    @NSManaged public var open: Bool
    @NSManaged public var searched: Bool

}

// MARK: Generated accessors for result
extension GoogleSearch {

    @objc(insertObject:inResultAtIndex:)
    @NSManaged public func insertIntoResult(_ value: GoogleSearchResult, at idx: Int)

    @objc(removeObjectFromResultAtIndex:)
    @NSManaged public func removeFromResult(at idx: Int)

    @objc(insertResult:atIndexes:)
    @NSManaged public func insertIntoResult(_ values: [GoogleSearchResult], at indexes: NSIndexSet)

    @objc(removeResultAtIndexes:)
    @NSManaged public func removeFromResult(at indexes: NSIndexSet)

    @objc(replaceObjectInResultAtIndex:withObject:)
    @NSManaged public func replaceResult(at idx: Int, with value: GoogleSearchResult)

    @objc(replaceResultAtIndexes:withResult:)
    @NSManaged public func replaceResult(at indexes: NSIndexSet, with values: [GoogleSearchResult])

    @objc(addResultObject:)
    @NSManaged public func addToResult(_ value: GoogleSearchResult)

    @objc(removeResultObject:)
    @NSManaged public func removeFromResult(_ value: GoogleSearchResult)

    @objc(addResult:)
    @NSManaged public func addToResult(_ values: NSOrderedSet)

    @objc(removeResult:)
    @NSManaged public func removeFromResult(_ values: NSOrderedSet)

}

extension GoogleSearch : Identifiable {

}
