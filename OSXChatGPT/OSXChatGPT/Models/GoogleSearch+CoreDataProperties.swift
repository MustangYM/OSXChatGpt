//
//  GoogleSearch+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/26.
//
//

import Foundation
import CoreData


extension GoogleSearch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoogleSearch> {
        return NSFetchRequest<GoogleSearch>(entityName: "GoogleSearch")
    }

    @NSManaged public var maxSearchResult: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var link: String?
    @NSManaged public var title: String?
    @NSManaged public var result: String?
    @NSManaged public var snippet: String?

}

extension GoogleSearch : Identifiable {

}
