//
//  UserRole+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//
//

import Foundation
import CoreData


extension UserRole {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserRole> {
        return NSFetchRequest<UserRole>(entityName: "UserRole")
    }

    @NSManaged public var role: String

}

extension UserRole : Identifiable {

}
