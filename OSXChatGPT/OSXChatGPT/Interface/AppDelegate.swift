//
//  AppDelegate.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    func applicationDidFinishLaunching(_ notification: Notification) {
        hideTheNavNar()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        hideTheNavNar()
    }

    private func filteringSpecialWindow(_ window: NSWindow) -> Bool {
        let list = ["NSStatusBarWindow", "_NSPopoverWindow"]
        for item in list {
            guard let clz = NSClassFromString(item) else { continue }
            if window.isKind(of: clz.self) { return false }
        }
        return true
    }
    
    private func hideTheNavNar() {
        if let window = NSApplication.shared.windows.first {
            self.window = window
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
        }
    }
}
