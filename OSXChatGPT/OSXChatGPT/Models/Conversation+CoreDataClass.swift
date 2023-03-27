//
//  Conversation+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/27.
//
//

import Foundation
import CoreData


public class Conversation: NSManagedObject {
    var lastInputText: String = ""
}
