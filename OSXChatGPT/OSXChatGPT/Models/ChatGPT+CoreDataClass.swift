//
//  ChatGPT+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/19.
//
//

import Foundation
import CoreData


public class ChatGPT: NSManagedObject {
    var modelType: ChatGPTModel {
        get {
            return ChatGPTModel(rawValue: model) ?? .gpt432k0314
        }
        set {
            model = newValue.rawValue
        }
    }
    var context: ChatGPTContext {
        get {
            return ChatGPTContext(rawValue: contextCount) ?? .context3
        }
        set {
            contextCount = newValue.rawValue
        }
    }
    var temperatureValue: String {
        let formattedValue = String(format: "%.1f", temperature)
        return formattedValue
    }
}
