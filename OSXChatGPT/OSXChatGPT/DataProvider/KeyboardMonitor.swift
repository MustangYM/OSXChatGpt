//
//  KeyboardMonitor.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/14.
//

import Cocoa

class KeyboardMonitor {
    static let shared = KeyboardMonitor()
    var shiftKeyPressed: Bool = false
    private var shiftKeyMonitor: Any?
    
    func startMonitorShiftKey() {
        if shiftKeyMonitor != nil {
            return
        }
        shiftKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: { event in
            if event.modifierFlags.contains(.shift) {
                print("按下shift健")
                self.shiftKeyPressed = true
            }else {
                print("松开shift健")
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
}
