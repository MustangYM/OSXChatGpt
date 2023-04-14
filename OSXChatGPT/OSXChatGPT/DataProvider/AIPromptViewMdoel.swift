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
        let request: NSFetchRequest<Prompt> = Prompt.fetchRequest()
        request.predicate = NSPredicate(format: "type == %d", PromptType.userLocalInUse.rawValue)
        let timestampSortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [timestampSortDescriptor]
        
        var aa: [Prompt] = CoreDataManager.shared.fetch(request: request)
        
        if let prompt = session.prompt {
            if aa.contains(where: {$0.id == prompt.id && $0.promptType != .hint}) {
                selectedItem = prompt
            }
        }
        aa.removeAll(where: {$0.promptType == .hint})
        let prompt = Prompt(context: CoreDataManager.shared.container.viewContext)
        prompt.promptType = .hint
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
        if prompt.promptType == .hint {
            return
        }
        prompt.promptType = .userLocal
        if let idx = allPrompts.firstIndex(where: {$0.id == prompt.id}) {
            allPrompts[idx].promptType = .userLocal
        }
        allPrompts.removeAll(where: {$0.promptType == .userLocal })
        if prompt.id == selectedItem?.id {
            selectedItem = allPrompts.first
        }
        CoreDataManager.shared.saveData()
    }
    
}

class AIPromptViewMdoel: ObservableObject {
    @Published var allPrompts: [Prompt] = []
    @Published var prompts: [Prompt] = []
    
    init() {
        fetchAllPrompts()
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
        prompt.promptType = .userLocal
        prompt.hexColor = NSColor.randomColor().toHexString()
        allPrompts.insert(prompt, at: 0)
        CoreDataManager.shared.saveData()
        if isToggleOn {
            HTTPClient.uploadPrompt(prompt: prompt)
        }
        
    }
    func updatePrompt(prompt: Prompt, isToggleOn: Bool) {
        if let idx = allPrompts.firstIndex(where: {$0.id == prompt.id}) {
            allPrompts[idx] = prompt
        }else {
            allPrompts.append(prompt)
        }
        
        CoreDataManager.shared.saveData()
        if isToggleOn {
            HTTPClient.uploadPrompt(prompt: prompt)
        }
        
    }
    func deletePrompt(prompt: Prompt) {
        allPrompts.removeAll(where: {$0.id == prompt.id})
        CoreDataManager.shared.delete(object: prompt)
        CoreDataManager.shared.saveData()
    }
    
}

extension AIPromptViewMdoel {
    private func fetchAllPrompts() {
        //删除云端数据
        let deleteRequest: NSFetchRequest<Prompt> = Prompt.fetchRequest()
        deleteRequest.predicate = NSPredicate(format: "type == 0")
        CoreDataManager.shared.delete(request: deleteRequest)
        
        //检索本地自定义数据
        let request: NSFetchRequest<Prompt> = Prompt.fetchRequest()
        let type2Predicate = NSPredicate(format: "type == %d", PromptType.userLocal.rawValue)
        let type3Predicate = NSPredicate(format: "type == %d", PromptType.userLocalInUse.rawValue)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [type2Predicate, type3Predicate])
        request.predicate = compoundPredicate
        
        
        let typeSortDescriptor = NSSortDescriptor(key: "type", ascending: false)
        let timestampSortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        request.sortDescriptors = [typeSortDescriptor, timestampSortDescriptor]
        var aa: [Prompt] = CoreDataManager.shared.fetch(request: request)
        
        //移除无效数据
        let remove = aa.filter { $0.title == nil || $0.prompt == nil || $0.id == nil}
        CoreDataManager.shared.delete(objects: remove)
        aa.removeAll { $0.title == nil || $0.prompt == nil || $0.id == nil }
        
        //赋值
        allPrompts = aa

        
        // 获取云端数据
        HTTPClient.getPrompt { [weak self] datas, err in
            print("云端数据请求成功")
            guard let self = self else { return }
            var temp: [Prompt] = []
            datas.forEach { json in
                if let jsonData = json as? [String: Any] {
                    if let idString = jsonData["idString"] as? String {
                        if !self.allPrompts.contains(where: {$0.idString == idString}) {
                            let p = Prompt(context: CoreDataManager.shared.container.viewContext)
                            p.id = UUID(uuidString: idString)
                            p.promptType = .cloud
                            p.createdDate = Date()
                            p.author = jsonData["author"] as? String
                            p.title = jsonData["title"] as? String
                            p.prompt = jsonData["prompt"] as? String
                            if let hexColor = jsonData["hexColor"] as? String, !hexColor.isEmpty {
                                p.hexColor = hexColor
                            }else {
                                p.hexColor = NSColor.randomColor().toHexString()
                            }
                            p.cloudId = jsonData["cloudId"] as? Int32 ?? 0
                            CoreDataManager.shared.saveData()
                            temp.append(p)
                        }
                    }else {
                        let p = Prompt(context: CoreDataManager.shared.container.viewContext)
                        p.id = UUID()
                        p.promptType = .cloud
                        p.createdDate = Date()
                        p.author = jsonData["author"] as? String
                        p.title = jsonData["title"] as? String
                        p.prompt = jsonData["prompt"] as? String
                        p.cloudId = jsonData["cloudId"] as? Int32 ?? 0
                        if let hexColor = jsonData["hexColor"] as? String, !hexColor.isEmpty {
                            p.hexColor = hexColor
                        }else {
                            p.hexColor = NSColor.randomColor().toHexString()
                        }
                        CoreDataManager.shared.saveData()
                        temp.append(p)
                    }
                }
            }
            if temp.count > 0 {
                self.allPrompts.forEach { p in
                    temp.removeAll(where: {$0.cloudId == p.cloudId})
                }
                DispatchQueue.main.async {
                    self.allPrompts += temp
                }
            }else {
                print("获取云端数据失败！！！需要更新token")
            }
        }
    }
    
    private func fetchPrompts() {
        let completedDateSort = NSSortDescriptor(keyPath: \Prompt.serial, ascending: false)
        let aa: [Prompt] = CoreDataManager.shared.fetch("Prompt", sorting: [completedDateSort])
        prompts = aa
    }
}



