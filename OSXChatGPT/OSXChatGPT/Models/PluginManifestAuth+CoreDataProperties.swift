//
//  PluginManifestAuth+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/6/26.
//
//

import Foundation
import CoreData


extension PluginManifestAuth {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PluginManifestAuth> {
        return NSFetchRequest<PluginManifestAuth>(entityName: "PluginManifestAuth")
    }

    @NSManaged public var type: String?

}

extension PluginManifestAuth : Identifiable {

}
