//
//  AIPromptViewMdoel.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/28.
//

import Foundation
import SwiftUI


class AIPromptViewMdoel {
    let isSession: Bool
    @Published var allPrompts: [Prompt] = []
    @Published var prompts: [Prompt] = []
    
    init(isSession: Bool) {
        self.isSession = isSession
        if isSession {
            fetchPrompts()
        }else {
            fetchAllPrompts()
        }
    }
    
    static func randomColor() -> Color {
        let color = Color(hue: Double.random(in: 0...1),
                          saturation: Double.random(in: 0.5...1),
                          brightness: Double.random(in: 0.5...1))
        return color
    }
    
    
}

extension AIPromptViewMdoel {
    private func fetchAllPrompts() {
        let completedDateSort = NSSortDescriptor(keyPath: \Prompt.serial, ascending: false)
        let aa: [Prompt] = CoreDataManager.shared.fetch("Prompt", sorting: [completedDateSort])
        allPrompts = aa
    }
    
    private func fetchPrompts() {
        let completedDateSort = NSSortDescriptor(keyPath: \Prompt.serial, ascending: false)
        let aa: [Prompt] = CoreDataManager.shared.fetch("Prompt", sorting: [completedDateSort])
        
        prompts = aa
    }
}



