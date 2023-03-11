//
//  ChatMessageView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI
import AppKit
/// main View
struct MainContentView: View {
    var body: some View {
        NavigationView {
            SessionsView()
            UserInitializeView()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

