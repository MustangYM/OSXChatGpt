//
//  Prompt+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/29.
//
//

import Foundation
import CoreData


extension Prompt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prompt> {
        return NSFetchRequest<Prompt>(entityName: OSXChatGPTPrompt)
    }

    @NSManaged public var author: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var prompt: String?
    @NSManaged public var serial: Int64
    @NSManaged public var title: String?
    @NSManaged public var type: Int16
    @NSManaged public var hexColor: String?
    @NSManaged public var sesstion: NSSet?

}

// MARK: Generated accessors for sesstion
extension Prompt {

    @objc(addSesstionObject:)
    @NSManaged public func addToSesstion(_ value: Conversation)

    @objc(removeSesstionObject:)
    @NSManaged public func removeFromSesstion(_ value: Conversation)

    @objc(addSesstion:)
    @NSManaged public func addToSesstion(_ values: NSSet)

    @objc(removeSesstion:)
    @NSManaged public func removeFromSesstion(_ values: NSSet)

}

extension Prompt : Identifiable {

}
