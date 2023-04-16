//
//  MessageText+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/15.
//
//

import Foundation
import CoreData


extension MessageText {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageText> {
        return NSFetchRequest<MessageText>(entityName: "MessageText")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var type: Int16
    @NSManaged public var isFull: Bool

}

extension MessageText : Identifiable {

}
