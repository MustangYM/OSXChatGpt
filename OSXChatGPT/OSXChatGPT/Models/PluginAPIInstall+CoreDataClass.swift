//
//  PluginAPIInstall+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/7/7.
//
//

import Foundation
import CoreData
import Yams


public class PluginAPIInstall: NSManagedObject {
    
    lazy var apiJson: [String: Any]? = {
        if let content = apiJsonString {
            let json = try? Yams.load(yaml: content) as? [String: Any]
            return json
        }
        return nil
    }()
}
