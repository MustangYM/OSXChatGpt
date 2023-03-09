//
//  Message+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var sesstionId: String
    @NSManaged public var id: UUID?
    @NSManaged public var type: Int16
    @NSManaged public var text: String?
    @NSManaged public var role: String?
    @NSManaged public var createdDate: Date?
    
}

extension Message : Identifiable {

}
