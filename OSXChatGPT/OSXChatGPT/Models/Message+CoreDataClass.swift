//
//  Message+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/16.
//
//

import Foundation
import CoreData

enum MessageType: Int16 {
    case normal = 0
    case waitingReply = 1//等待回复
    case fialMsg = 2//错误消息
}

enum MessageTextType: Int16 {
    case none = 0
    case text = 1//文本
    case code = 2//代码
    case full = 3//完整了
}


public class Message: NSManagedObject {
    
    var tempText: MessageText?
    
    var msgTextType: MessageTextType {
        get {
            return MessageTextType(rawValue: textType) ?? .none
        }
        set {
            textType = newValue.rawValue
        }
    }
    
    var msgType: MessageType {
        get {
            return MessageType(rawValue: type) ?? .normal
        }
        set {
            type = newValue.rawValue
        }
    }
}
