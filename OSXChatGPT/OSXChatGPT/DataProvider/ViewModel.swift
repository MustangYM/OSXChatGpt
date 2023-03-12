//
//  ViewModel.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//

import Foundation
import SwiftUI
import CoreData

@MainActor class ViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    var currentConversation: Conversation?
    var isNewConversation: Bool = false
    init() {
        fetchConversations()
    }
    func updateConversation(sesstionId: String, message: Message?) {
        var con = fetchConversation(sesstionId: sesstionId)
        if con == nil {
            con = Conversation(context: CoreDataManager.shared.container.viewContext)
            con?.sesstionId = sesstionId
            con?.id = UUID()
        }
        con!.lastMessage = message
        con!.updateData = Date()
        CoreDataManager.shared.saveData()
        
        if let index = conversations.firstIndex(where: { $0.sesstionId == sesstionId}) {
            conversations[index] = con!
        } else {
            conversations.insert(con!, at: 0)
        }
    }
    func updateConversation(sesstionId: String, remark: String?) {
        var con = fetchConversation(sesstionId: sesstionId)
        if con == nil {
            con = Conversation(context: CoreDataManager.shared.container.viewContext)
            con?.sesstionId = sesstionId
            con?.id = UUID()
            con?.updateData = Date()
        }
        con?.remark = remark
        CoreDataManager.shared.saveData()
        if let index = conversations.firstIndex(where: { $0.sesstionId == sesstionId}) {
            conversations[index] = con!
        }
    }
    
    //**这里是一个Fake会话, 不需要存入数据库
    func addNewConversation() -> Conversation {
        if (currentConversation != nil) && currentConversation!.lastMessage == nil {
            return currentConversation!
        }
        
        let con = Conversation(context: CoreDataManager.shared.container.viewContext)
        con.sesstionId = createSesstionId()
        con.id = UUID()
        con.updateData = Date()
        //**这里是一个Fake会话, 不需要存入数据库
//        CoreDataManager.shared.saveData()
        currentConversation = con
        return con
    }
    func addConversation() {
        let con = Conversation(context: CoreDataManager.shared.container.viewContext)
        con.sesstionId = createSesstionId()
        con.updateData = Date()
        con.id = UUID()
        CoreDataManager.shared.saveData()
        fetchConversations()
    }
    func deleteConversation(_ conversation: Conversation) {
        CoreDataManager.shared.delete(objects: [conversation])
        conversations.removeAll { $0.sesstionId == conversation.sesstionId }
    }
    
    func fetchMessage(sesstionId: String) {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "sesstionId == %@", sesstionId)
        let timestampSortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
        request.sortDescriptors = [timestampSortDescriptor]
        let results: [Message] = CoreDataManager.shared.fetch(request: request)
        messages = results
    }
    
    func addNewMessage(sesstionId: String, text: String, role: String, updateBlock: @escaping(() -> ())) {
        let msg = Message(context: CoreDataManager.shared.container.viewContext)
        msg.sesstionId = sesstionId
        msg.text = text
        msg.role = role
        msg.id = UUID()
        msg.createdDate = Date()
        CoreDataManager.shared.saveData()
        messages.append(msg)
        updateConversation(sesstionId: sesstionId, message:messages.last)
        ChatGPTManager.shared.askChatGPT(messages: messages) { json, error in
            if let err = error {
                print("\(err)")
                return
            }
            let choices = json?["choices"] as? [Any]
            let choice = choices?[0] as? [String: Any]
            let myMessage = choice?["message"] as? [String: Any]
            let content = myMessage?["content"] as? String
            let roleStr = myMessage?["role"] as? String
            let msg = Message(context: CoreDataManager.shared.container.viewContext)
            msg.sesstionId = sesstionId
            msg.role = roleStr ?? ChatGPTManager.shared.gptRoleString
            msg.text = content ?? ""
            msg.text = msg.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            msg.createdDate = Date()
            msg.id = UUID()
            CoreDataManager.shared.saveData()
            self.messages.append(msg)
            self.updateConversation(sesstionId: sesstionId, message: self.messages.last)
            updateBlock()
            print("回答的内容：\(String(describing: content))")
        }
    }
    func createSesstionId() -> String {
        let aa = Date.now.timeIntervalSince1970 * 1000
        return String(aa)
    }
}

extension ViewModel {
    private func getNowData() -> Int64 {
        return Int64(Date.now.timeIntervalSince1970)
    }
}

extension ViewModel {
    func fetchConversations() {
        let completedDateSort = NSSortDescriptor(keyPath: \Conversation.updateData, ascending: false)
        var aa: [Conversation] = CoreDataManager.shared.fetch("Conversation", sorting: [completedDateSort])
        let remove = aa.filter { $0.lastMessage == nil}
        CoreDataManager.shared.delete(objects: remove)
        aa.removeAll { $0.lastMessage == nil}
        conversations = aa
    }
    private func fetchConversation(sesstionId: String) -> Conversation? {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "sesstionId == %@", sesstionId)
        let results: [Conversation] = CoreDataManager.shared.fetch(request: request)
        return results.first
        
    }
}
