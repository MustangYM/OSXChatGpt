//
//  AIPromptViewMdoel.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/28.
//

import Foundation
import SwiftUI

class AIPromptSessionViewMdoel: ObservableObject {
    @Published var allPrompts: [Prompt] = []
    @Published var selectedItem :Prompt?
    
    func fetchAllPrompts(session: Conversation) {
        let completedDateSort = NSSortDescriptor(keyPath: \Prompt.serial, ascending: false)
        var aa: [Prompt] = CoreDataManager.shared.fetch("Prompt", sorting: [completedDateSort])
        
        if (aa.count == 0) {
            aa = AIPromptSessionViewMdoel.createDefaultPrompt()
        }
        
        if let prompt = session.prompt {
            if aa.contains(where: {$0.id == prompt.id}) {
                selectedItem = prompt
            }
        }
        
        aa.removeAll(where: {$0.type == 1})
        let prompt = Prompt(context: CoreDataManager.shared.container.viewContext)
        prompt.type = 1
        prompt.id = UUID()
        prompt.createdDate = Date()
        prompt.hexColor = "#999999"
        aa.insert(prompt, at: 0)
        if selectedItem == nil {
            selectedItem = prompt
        }
        
        CoreDataManager.shared.saveData()
        allPrompts = aa
    }
    
    func deletePrompt(prompt: Prompt) {
        if prompt.type == 1 {
            return
        }
        allPrompts.removeAll(where: {$0.id == prompt.id})
        if prompt.id == selectedItem?.id {
            selectedItem = allPrompts.first
        }
        CoreDataManager.shared.delete(object: prompt)
    }
    
    static func createDefaultPrompt() -> [Prompt] {
        var temp: [Prompt] = []
        let prompt1 = Prompt(context: CoreDataManager.shared.container.viewContext)
        prompt1.id = UUID()
        prompt1.createdDate = Date()
        prompt1.title = "翻译"
        prompt1.prompt = "翻译我说的任何中文或英文。只返回翻译结果，不解释它"
        prompt1.hexColor = NSColor.randomColor().toHexString()
        temp.append(prompt1)
        
        let prompt2 = Prompt(context: CoreDataManager.shared.container.viewContext)
        prompt2.id = UUID()
        prompt2.createdDate = Date()
        prompt2.title = "iOS开发者"
        prompt2.prompt = "假设你是一名iOS开发者，使用的是swift语言"
        prompt2.hexColor = NSColor.randomColor().toHexString()
        temp.append(prompt2)
        
        
        CoreDataManager.shared.saveData()
        return temp
    }
    
}

class AIPromptViewMdoel: ObservableObject {
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
    
    
    func addPrompt(title: String, content: String) {
        let prompt = Prompt(context: CoreDataManager.shared.container.viewContext)
        prompt.title = title
        prompt.prompt = content
        prompt.id = UUID()
        prompt.createdDate = Date()
        CoreDataManager.shared.saveData()
        
//        AIPromptDataManager.shared.addPrompt(prompt: prompt)
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



