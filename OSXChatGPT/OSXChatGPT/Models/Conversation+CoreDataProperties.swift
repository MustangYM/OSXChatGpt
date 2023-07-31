//
//  Conversation+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/7/12.
//
//

import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var remark: String?
    @NSManaged public var sesstionId: String
    @NSManaged public var updateData: Date?
    @NSManaged public var chatGPT: ChatGPT?
    @NSManaged public var lastMessage: Message?
    @NSManaged public var prompt: Prompt?
    @NSManaged public var search: GoogleSearch?
    @NSManaged public var plugin: NSOrderedSet?

}

// MARK: Generated accessors for plugin
extension Conversation {

    @objc(insertObject:inPluginAtIndex:)
    @NSManaged public func insertIntoPlugin(_ value: PluginAPIInstall, at idx: Int)

    @objc(removeObjectFromPluginAtIndex:)
    @NSManaged public func removeFromPlugin(at idx: Int)

    @objc(insertPlugin:atIndexes:)
    @NSManaged public func insertIntoPlugin(_ values: [PluginAPIInstall], at indexes: NSIndexSet)

    @objc(removePluginAtIndexes:)
    @NSManaged public func removeFromPlugin(at indexes: NSIndexSet)

    @objc(replaceObjectInPluginAtIndex:withObject:)
    @NSManaged public func replacePlugin(at idx: Int, with value: PluginAPIInstall)

    @objc(replacePluginAtIndexes:withPlugin:)
    @NSManaged public func replacePlugin(at indexes: NSIndexSet, with values: [PluginAPIInstall])

    @objc(addPluginObject:)
    @NSManaged public func addToPlugin(_ value: PluginAPIInstall)

    @objc(removePluginObject:)
    @NSManaged public func removeFromPlugin(_ value: PluginAPIInstall)

    @objc(addPlugin:)
    @NSManaged public func addToPlugin(_ values: NSOrderedSet)

    @objc(removePlugin:)
    @NSManaged public func removeFromPlugin(_ values: NSOrderedSet)

}

extension Conversation : Identifiable {

}
