//
//  Conversation+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//
//

import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }

    @NSManaged public var sesstionId: String
    @NSManaged public var updateData: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var lastMessage: Message?
}

extension Conversation : Identifiable {

}
