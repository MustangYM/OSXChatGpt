//
//  ProjectSettingManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/12.
//

import Foundation

class ProjectSettingManager {
    static let shared = ProjectSettingManager()
    private init() {}
    
    ///显示动态背景
    var showDynamicBackground: Bool {
        get {
            let show = UserDefaults.standard.bool(forKey: "kshowDynamicBackground_key")
            return show
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kshowDynamicBackground_key")
        }
    }
    
    
    
    
}
