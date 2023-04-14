//
//  AIPromptDataManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/29.
//

import Foundation


class AIPromptDataManager {
    static var shared = AIPromptDataManager()
    
    var allPrompts: [Prompt] = []
    
    
    init() {
        fetchAllPrompts()
    }
    
    
    func addPrompt(prompt: Prompt) {
        
    }
    
    func deletePrompt(prompt: Prompt) {
        
    }
    
}

extension AIPromptDataManager {
    private func fetchAllPrompts() {
        let completedDateSort = NSSortDescriptor(keyPath: \Prompt.createdDate, ascending: false)
        let aa: [Prompt] = CoreDataManager.shared.fetch(OSXChatGPTPrompt, sorting: [completedDateSort])
        allPrompts = aa
    }
}
