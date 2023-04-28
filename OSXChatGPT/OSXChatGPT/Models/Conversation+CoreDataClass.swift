//
//  Conversation+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/26.
//
//

import Foundation
import CoreData


public class Conversation: NSManagedObject {
    var lastInputText: String = ""
}
