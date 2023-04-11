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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ColorfulView(colors: [.accentColor], colorCount: 1)
                    .ignoresSafeArea()
                MainContentView().environmentObject(viewModel).edgesIgnoringSafeArea(.top).frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            }
        }
        .windowToolbarStyle(.unified)
        .commands { SidebarCommands() }
        .commands { CommandGroup(replacing: CommandGroupPlacement.newItem) {} }
    }
}

