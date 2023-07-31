//
//  PluginManifestAPI+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/6/26.
//
//

import Foundation
import CoreData


extension PluginManifestAPI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PluginManifestAPI> {
        return NSFetchRequest<PluginManifestAPI>(entityName: "PluginManifestAPI")
    }

    @NSManaged public var type: String?
    @NSManaged public var url: String?
    @NSManaged public var has_user_authentication: Bool

}

extension PluginManifestAPI : Identifiable {

}
