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
}
