//
//  SystemManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/31.
//

import Foundation


class SystemManager {
    static let shared = SystemManager()
    
    lazy var userName: String? = {
        self.getUsername()
    }()
    
    lazy var OSVersion: String? = {
        self.getOSVersion()
    }()
    
    private init() {
        let _ = self.userName
        let _ = self.OSVersion
    }
    
    private func getUsername() -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/whoami"
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let userName = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return userName
    }
    
    private func getOSVersion() -> String? {
        let task = Process()
        task.launchPath = "/usr/bin/sw_vers"
        task.arguments = ["-productVersion"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let versionString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
        return versionString
    }
    
}
