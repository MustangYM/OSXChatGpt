//
//  MessageTextModel.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/14.
//

import Foundation


//enum MessageTextType {
//    case text
//    case code
//}

struct MessageTextModel: Hashable {
    var id: UUID = UUID()
    var type: MessageTextType = .text
    var text: String = ""
    var headText: String = ""
    var attText: AttributedString = ""
    var isFull: Bool = false
}
