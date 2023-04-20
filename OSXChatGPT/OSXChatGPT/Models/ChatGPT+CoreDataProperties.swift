//
//  ChatGPT+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/19.
//
//

import Foundation
import CoreData


extension ChatGPT {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatGPT> {
        return NSFetchRequest<ChatGPT>(entityName: "ChatGPT")
    }

    @NSManaged public var contextCount: Int16
    @NSManaged public var model: Int16
    @NSManaged public var temperature: Double
    @NSManaged public var id: UUID?

}

extension ChatGPT : Identifiable {

}
