//
//  Message+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/16.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var createdDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var role: String?
    @NSManaged public var sesstionId: String?
    @NSManaged public var text: String?
    @NSManaged public var type: Int16
    @NSManaged public var textType: Int16
    @NSManaged public var textModel: NSOrderedSet

}

// MARK: Generated accessors for textModel
extension Message {

    @objc(insertObject:inTextModelAtIndex:)
    @NSManaged public func insertIntoTextModel(_ value: MessageText, at idx: Int)

    @objc(removeObjectFromTextModelAtIndex:)
    @NSManaged public func removeFromTextModel(at idx: Int)

    @objc(insertTextModel:atIndexes:)
    @NSManaged public func insertIntoTextModel(_ values: [MessageText], at indexes: NSIndexSet)

    @objc(removeTextModelAtIndexes:)
    @NSManaged public func removeFromTextModel(at indexes: NSIndexSet)

    @objc(replaceObjectInTextModelAtIndex:withObject:)
    @NSManaged public func replaceTextModel(at idx: Int, with value: MessageText)

    @objc(replaceTextModelAtIndexes:withTextModel:)
    @NSManaged public func replaceTextModel(at indexes: NSIndexSet, with values: [MessageText])

    @objc(addTextModelObject:)
    @NSManaged public func addToTextModel(_ value: MessageText)

    @objc(removeTextModelObject:)
    @NSManaged public func removeFromTextModel(_ value: MessageText)

    @objc(addTextModel:)
    @NSManaged public func addToTextModel(_ values: NSOrderedSet)

    @objc(removeTextModel:)
    @NSManaged public func removeFromTextModel(_ values: NSOrderedSet)

}

extension Message : Identifiable {

}
