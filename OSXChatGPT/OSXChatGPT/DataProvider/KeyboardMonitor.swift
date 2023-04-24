//
//  KeyboardMonitor.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/14.
//

import Cocoa
import AppKit

class KeyboardMonitor {
    static let shared = KeyboardMonitor()
    var shiftKeyPressed: Bool = false
    private var shiftKeyMonitor: Any?
    private var changeCount: Int = NSPasteboard.general.changeCount
    
    private var pasteboardTimer: Timer?
    private let pasteboard = NSPasteboard.general
    var currentPasteboardText: String = ""
    
    func startMonitorShiftKey() {
        if shiftKeyMonitor != nil {
            return
        }
        shiftKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: { event in
            if event.modifierFlags.contains(.shift) {
//                print("按下shift健")
                self.shiftKeyPressed = true
            }else {
//                print("松开shift健")
                self.shiftKeyPressed = false
            }
            return event
        })
    }
    
    func stopKeyMonitor() {
        if let monitor = shiftKeyMonitor {
            NSEvent.removeMonitor(monitor)
            self.shiftKeyMonitor = nil
        }
    }
    
    func startMonitorPasteboard() {
        if pasteboardTimer != nil {
            return
        }
        if let text = pasteboard.string(forType: .string) {
            self.currentPasteboardText = text
        }
        pasteboardTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkPasteboard), userInfo: nil, repeats: true)
    }
    
    func stopMonitorPasteboard() {
        if pasteboardTimer != nil {
            pasteboardTimer?.invalidate()
            pasteboardTimer = nil
        }
    }
    @objc private func checkPasteboard() {
        if self.changeCount != pasteboard.changeCount {
            if let text = pasteboard.string(forType: .string) {
                self.currentPasteboardText = text
            }
        }
        self.changeCount = pasteboard.changeCount
    }
}
