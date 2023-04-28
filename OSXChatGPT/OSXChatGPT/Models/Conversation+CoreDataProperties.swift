//
//  Conversation+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/26.
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

}

extension Conversation : Identifiable {

}
