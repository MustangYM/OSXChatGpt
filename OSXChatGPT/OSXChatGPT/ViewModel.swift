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
        con?.lastMessage = message
        con?.updateData = Date()
        CoreDataManager.shared.saveData()
//        if let idx = conversations.firstIndex(where:{ $0.sesstionId == sesstionId }) {
//            conversations[idx].lastMessage = message
//        }
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
            msg.role = roleStr ?? ""
            msg.text = content ?? ""
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
        conversations = CoreDataManager.shared.fetch("Conversation", sorting: [completedDateSort])
    }
    private func fetchConversation(sesstionId: String) -> Conversation? {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "sesstionId == %@", sesstionId)
        let results: [Conversation] = CoreDataManager.shared.fetch(request: request)
        return results.first
        
    }
}
