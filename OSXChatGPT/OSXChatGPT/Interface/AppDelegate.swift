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
        
        if #available(OSX 10.14, *) {
            NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        hideTheNavNar()
    }
    
    func applicationDidUnhide(_ notification: Notification) {
        hideTheNavNar()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        hideTheNavNar()
        return true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
            for window in NSApplication.shared.windows {
                self.window = window
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
            }
        }
    }
}
