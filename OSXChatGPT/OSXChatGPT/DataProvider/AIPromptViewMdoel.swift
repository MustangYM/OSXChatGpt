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
        let completedDateSort = NSSortDescriptor(keyPath: \Prompt.createdDate, ascending: false)
        var aa: [Prompt] = CoreDataManager.shared.fetch("Prompt", sorting: [completedDateSort])
        if (aa.count == 0) {
            aa = AIPromptSessionViewMdoel.createDefaultPrompt()
        }
        if let prompt = session.prompt {
            if aa.contains(where: {$0.id == prompt.id && $0.type != 1}) {
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
        
        // 获取云端数据
        HTTPClient.getPrompt { [weak self] datas, err in
            print("获取云端数据成功")
            guard let self = self else { return }
            var temp: [Prompt] = []
            datas.forEach { json in
                if let jsonData = json as? [String: Any] {
                    if let idString = jsonData["idString"] as? String {
                        if !self.allPrompts.contains(where: {$0.idString == idString}) {
                            let p = Prompt(context: CoreDataManager.shared.container.viewContext)
                            p.id = UUID(uuidString: idString)
                            p.createdDate = Date()
                            p.author = jsonData["author"] as? String
                            p.title = jsonData["title"] as? String
                            p.prompt = jsonData["prompt"] as? String
                            p.hexColor = NSColor.randomColor().toHexString()
                            CoreDataManager.shared.saveData()
                            temp.append(p)
                        }
                    }else {
                        let p = Prompt(context: CoreDataManager.shared.container.viewContext)
                        p.id = UUID()
                        p.createdDate = Date()
                        p.author = jsonData["author"] as? String
                        p.title = jsonData["title"] as? String
                        p.prompt = jsonData["prompt"] as? String
                        p.hexColor = NSColor.randomColor().toHexString()
                        CoreDataManager.shared.saveData()
                        temp.append(p)
                    }
                }
            }
            if temp.count > 0 {
                DispatchQueue.main.async {
                    self.allPrompts += temp
                }
            }
        }
        
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
    
    
    func addPrompt(title: String, content: String, author: String, isToggleOn: Bool) {
        let prompt = Prompt(context: CoreDataManager.shared.container.viewContext)
        prompt.title = title
        prompt.prompt = content
        prompt.author = author
        prompt.id = UUID()
        prompt.createdDate = Date()
        CoreDataManager.shared.saveData()
        if isToggleOn {
            HTTPClient.uploadPrompt(prompt: prompt)
        }
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



