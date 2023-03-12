//
//  ChatRoomCellView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI
import AppKit
/// main View
struct MainContentView: View {
    @State var openArgumentsSeet: Bool = false
    var body: some View {
        NavigationView {
            SessionsView()
            UserInitializeView()
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(
                        #selector(NSSplitViewController.toggleSidebar(_:)),
                        with: nil
                    )
                } label: {
                    Label("Toggle Sidebar", systemImage: "sidebar.leading")
                }
            }
        }
        
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

