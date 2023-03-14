//
//  Config.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/12.
//

import Combine
import Foundation


class Config: ObservableObject {
    static let shared = Config()
    public var CurrentSession : String = ""
    public let chatGptThinkSession: String = "chatGptThinkSessionID"
}
