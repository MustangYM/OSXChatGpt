//
//  GoogleSearchResult+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/28.
//
//

import Foundation
import CoreData


extension GoogleSearchResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoogleSearchResult> {
        return NSFetchRequest<GoogleSearchResult>(entityName: "GoogleSearchResult")
    }

    @NSManaged public var title: String?
    @NSManaged public var snippet: String?
    @NSManaged public var result: String?
    @NSManaged public var link: String?
    @NSManaged public var id: UUID?

}

extension GoogleSearchResult : Identifiable {

}
