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
    @Published var conversations: [Conversation] = []//所有会话
    @Published var messages: [Message] = []//当前会话的消息
    @Published var showUserInitialize: Bool = false//显示设置页
    @Published var showEditRemark: Bool = false//显示编辑备注
    var editConversation: Conversation?//编辑备注的会话
    @Published var createNewChat: Bool = false//创建新会话
    
    
    var currentConversation: Conversation?//当前会话
    
    
    private var allChatRoomViews: [String:ChatRoomView] = [:]
    
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
    class func addNewConversation() -> Conversation {
        let con = Conversation(context: CoreDataManager.shared.container.viewContext)
        con.sesstionId = createSesstionId()
        con.id = UUID()
        con.updateData = Date()
        return con
    }
    //**这里是一个Fake会话, 不需要存入数据库
    func addNewConversation() -> Conversation {
        let con = Conversation(context: CoreDataManager.shared.container.viewContext)
        con.sesstionId = createSesstionId()
        con.id = UUID()
        con.updateData = Date()
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
        conversations.removeAll { $0.sesstionId == conversation.sesstionId }
        CoreDataManager.shared.delete(objects: [conversation])
        if currentConversation?.sesstionId == conversation.sesstionId {
            currentConversation = nil
        }
    }
    
    func fetchMessage(sesstionId: String) {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "sesstionId == %@", sesstionId)
        let timestampSortDescriptor = NSSortDescriptor(key: "createdDate", ascending: true)
        request.sortDescriptors = [timestampSortDescriptor]
        var results: [Message] = CoreDataManager.shared.fetch(request: request)
        if let last = results.last {
            if last.role == ChatGPTManager.shared.gptRoleString {
                //最后一条是gpt消息，并且已经回复，则删除以前的回复中
                if last.type != 1 {
                    let thinks = results.filter({$0.type == 1 })
                    if thinks.count > 0 {
                        results.removeAll(where: {$0.type == 1})
                        CoreDataManager.shared.delete(objects: thinks)
                    }
                }
            }
        }
        
        messages = results
    }
    func addGptThinkMessage(sesstionId: String) {
        removeGptThinkMessage()
        
        let msg = Message(context: CoreDataManager.shared.container.viewContext)
        msg.sesstionId = sesstionId
        msg.id = UUID()
        msg.createdDate = Date()
        msg.text = "......"
        msg.role = ChatGPTManager.shared.gptRoleString
        msg.type = 1
        messages.append(msg)
        CoreDataManager.shared.saveData()
    }
    func removeGptThinkMessage() {
        let msg = messages.filter({ $0.type == 1})
        if msg.count == 0 {
            return
        }
        if messages.contains(where: { $0.type == 1}) {
            messages.removeAll(where: { $0.type == 1} )
        }
        CoreDataManager.shared.delete(objects: msg)
        
    }
    func addNewMessage(sesstionId: String, text: String, role: String, updateBlock: @escaping(() -> ())) {
        if sesstionId.isEmpty {
            return
        }
        let msg = Message(context: CoreDataManager.shared.container.viewContext)
        msg.sesstionId = sesstionId
        msg.text = text
        msg.role = role
        msg.id = UUID()
        msg.createdDate = Date()
        messages.append(msg)
        CoreDataManager.shared.saveData()
        updateConversation(sesstionId: sesstionId, message:messages.last)
        print("发送问题：\(text)")
        var sendMsgs = messages
        sendMsgs.removeAll(where: {$0.type == 1})
        var isFeedback = false
        ChatGPTManager.shared.askChatGPT(messages: sendMsgs) { json, error in
            if let err = error {
                print("\(err)")
                self.removeGptThinkMessage()
                CoreDataManager.shared.saveData()
                let msg = Message(context: CoreDataManager.shared.container.viewContext)
                msg.sesstionId = sesstionId
                msg.role = ChatGPTManager.shared.gptRoleString
                msg.text = "啊哦～连接失败了！"
                msg.createdDate = Date()
                msg.id = UUID()
                CoreDataManager.shared.saveData()
                if self.currentConversation?.sesstionId == sesstionId {
                    self.messages.append(msg)
                }
                self.updateConversation(sesstionId: sesstionId, message: msg)
                updateBlock()
                isFeedback = true
                return
            }
            self.removeGptThinkMessage()
            CoreDataManager.shared.saveData()
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
            if self.currentConversation?.sesstionId == sesstionId {
                self.messages.append(msg)
            }
            self.updateConversation(sesstionId: sesstionId, message: msg)
            updateBlock()
            isFeedback = true
            print("回答的内容：\(String(describing: content))")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !isFeedback {
                self.addGptThinkMessage(sesstionId: sesstionId)
                
            }
        }
    }
    func createSesstionId() -> String {
        if #available(macOS 12, *) {
            return String(Date.now.timeIntervalSince1970 * 1000)
        } else {
            return String(Date().timeIntervalSince1970 * 1000)
        }
    }
    
    class func createSesstionId() -> String {
        if #available(macOS 12, *) {
            return String(Date.now.timeIntervalSince1970 * 1000)
        } else {
            return String(Date().timeIntervalSince1970 * 1000)
        }
    }
    
}
extension ViewModel {
    func getChatRoomView(conversation: Conversation?) -> ChatRoomView {
        if conversation == nil || conversation!.sesstionId == "" {
            let view = ChatRoomView(conversation: conversation)
            return view
        }
        if let view = allChatRoomViews[conversation?.sesstionId ?? ""] {
            return view
        }
        let view = ChatRoomView(conversation: conversation)
        allChatRoomViews[conversation!.sesstionId] = view
        return view
    }
}

extension ViewModel {
    private func getNowData() -> Int64 {
        if #available(macOS 12, *) {
            return Int64(Date.now.timeIntervalSince1970)
        } else {
            return Int64(Date().timeIntervalSince1970)
        }
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
