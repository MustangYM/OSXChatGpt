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
    @State private var showSettings = false
    var body: some Scene {
        WindowGroup {
            ZStack {
                if viewModel.showDynamicBackground {
                    ColorfulView(colors: [.accentColor], colorCount: 1)
                        .ignoresSafeArea()
                }
                MainContentView().environmentObject(viewModel).edgesIgnoringSafeArea(.top).frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                    .onAppear {
                                if showSettings {
                                    openSettingsWindow()
                                }
                            }
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
//        .commands {
//            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
////                Button("Custom Shortcut") {
////                    // 在这里添加自定义快捷键触发时的操作
////                    print("Custom Shortcut Triggered")
////                    NSApplication.shared.hide(nil)
////                }
////                .keyboardShortcut(KeyEquivalent("N"), modifiers: .command)
//                Button(Localization.Setting.localized) {
////                    showSettings.toggle()
//                    openSettingsWindow()
//                    print("Localization.Setting.localized")
//
//                }
//                .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
//            }
//        }
        
        
        
    }
    
    func openSettingsWindow() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let settingsWindowController = NSWindowController(window: settingsWindow)
        settingsWindowController.contentViewController = NSHostingController(rootView: SettingsView())
        
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}



