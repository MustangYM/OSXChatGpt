//
//  Message+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//
//

import Foundation
import CoreData

enum MessageType: Int16 {
    case normal = 0
    case waitingReply = 1//等待回复
    case fialMsg = 2//错误消息
}


public class Message: NSManagedObject {
    var msgType: MessageType {
        get {
            return MessageType(rawValue: type) ?? .normal
        }
        set {
            type = newValue.rawValue
        }
    }
}
