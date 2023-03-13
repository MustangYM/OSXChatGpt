//
//  MessageTextModel.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/13.
//

import Foundation
enum MessageTextType {
    case text
    case code
}

struct MessageTextModel: Hashable {
    var id: UUID = UUID()
    var type: MessageTextType = .text
    var text: String = ""
    var headText: String = ""
}
