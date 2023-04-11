//
//  Prompt+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/29.
//
//

import Foundation
import CoreData
import SwiftUI


enum PromptType: Int16 {
    case cloud = 0 //云端数据
    case hint = 1//提示
    case userLocal = 2//用户本地数据，未使用
    case userLocalInUse = 3//用户本地数据,使用中
}


public class Prompt: NSManagedObject {
    var idString: String {
        return id!.uuidString
    }
    var color: Color {
        if let hex = hexColor {
            return NSColor(hex: hex).toColor()
        }else {
            let hex = NSColor.randomColor().toHexString()
            hexColor = hex
            CoreDataManager.shared.saveData()
            return NSColor(hex: hex).toColor()
        }
        
    }
    var promptType: PromptType {
        get {
            return PromptType(rawValue: type) ?? .cloud
        }
        set {
            type = newValue.rawValue
        }
    }
}
