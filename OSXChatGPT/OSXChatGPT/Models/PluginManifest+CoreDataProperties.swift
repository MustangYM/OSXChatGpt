//
//  PluginManifest+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/7/7.
//
//

import Foundation
import CoreData


extension PluginManifest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PluginManifest> {
        return NSFetchRequest<PluginManifest>(entityName: "PluginManifest")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var schema_version: String?
    @NSManaged public var name_for_human: String?
    @NSManaged public var name_for_model: String?
    @NSManaged public var description_for_human: String?
    @NSManaged public var description_for_model: String?
    @NSManaged public var logo_url: String?
    @NSManaged public var contact_email: String?
    @NSManaged public var legal_info_url: String?
    @NSManaged public var api: PluginManifestAPI?
    @NSManaged public var auth: PluginManifestAuth?
    @NSManaged public var install: PluginAPIInstall?

}

extension PluginManifest : Identifiable {

}
