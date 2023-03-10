//
//  OSXChatGPTApp.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI
import Colorful
@main
struct OSXChatGPTApp: App {
    @StateObject var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            ZStack {
                ColorfulView(colors: [.accentColor], colorCount: 10)
                    .ignoresSafeArea()
               ContentView().environmentObject(viewModel).edgesIgnoringSafeArea(.top).frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            }
        }//toolBar的大小样式
        .windowToolbarStyle(.unified)
        .commands { SidebarCommands() }
        .commands { CommandGroup(replacing: CommandGroupPlacement.newItem) {} }
    }
}
