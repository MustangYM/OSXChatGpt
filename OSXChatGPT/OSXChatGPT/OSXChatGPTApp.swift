//
//  OSXChatGPTApp.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI

@main
struct OSXChatGPTApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ChatGPTManager.shared.allConversations)
        }
    }
}
