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
                if viewModel.showDynamicBackground {
                    ColorfulView(colors: [.accentColor], colorCount: 1)
                        .ignoresSafeArea()
                }
                MainContentView().environmentObject(viewModel).edgesIgnoringSafeArea(.top).frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            }
        }
        .windowToolbarStyle(.unified)
        .commands { SidebarCommands() }
        .commands { CommandGroup(replacing: CommandGroupPlacement.newItem) {} }
        .commands {
            CommandMenu(Localization.Setting.localized) {
                Menu(viewModel.showDynamicBackground ? Localization.HideDynamicBackground.localized : Localization.DisplayDynamicBackground.localized) {
                    Text(viewModel.showDynamicBackground ? Localization.Displayed.localized : Localization.Hidden.localized)
                } primaryAction: {
                    viewModel.showDynamicBackground.toggle()
                    ProjectSettingManager.shared.showDynamicBackground = viewModel.showDynamicBackground
                    viewModel.showDynamicBackground = viewModel.showDynamicBackground
                }
            }
        }
    }
}

