//
//  MessageText+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/15.
//
//

import Foundation
import CoreData


public class MessageText: NSManagedObject {
    var attString: AttributedString = ""
    var textType: MessageTextType {
        get {
            return MessageTextType(rawValue: type) ?? .none
        }
        set {
            type = newValue.rawValue
        }
    }
}
