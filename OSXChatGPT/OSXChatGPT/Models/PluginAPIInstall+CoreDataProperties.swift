//
//  PluginAPIInstall+CoreDataProperties.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/7/7.
//
//

import Foundation
import CoreData


extension PluginAPIInstall {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PluginAPIInstall> {
        return NSFetchRequest<PluginAPIInstall>(entityName: "PluginAPIInstall")
    }

    @NSManaged public var apiJsonString: String?
    @NSManaged public var schema_version: String?
    @NSManaged public var logo_url: String?
    @NSManaged public var name_for_human: String?
    @NSManaged public var description_for_human: String?
}

extension PluginAPIInstall : Identifiable {

}
