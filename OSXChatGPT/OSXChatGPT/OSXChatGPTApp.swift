//
//  OSXChatGPTApp.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI

@main
struct OSXChatGPTApp: App {
    @StateObject var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }//toolBar的大小样式
        .windowToolbarStyle(.expanded)
        .commands { SidebarCommands() }
        .commands { CommandGroup(replacing: CommandGroupPlacement.newItem) {} }
    }
}
