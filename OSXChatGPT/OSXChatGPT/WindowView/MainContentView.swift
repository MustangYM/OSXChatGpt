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
    var body: some View {
        NavigationView {
            SessionsView()
        }
        .padding(.bottom, -6)
        .toolbar {
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
        }.tabViewStyle(.automatic)
            
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

