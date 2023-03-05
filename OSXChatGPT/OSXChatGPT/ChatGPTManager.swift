//
//  ChatGPTManager.swift
//  OSXChatGPT
//
//  Created by 陈连辰 on 2023/3/5.
//

import Foundation

class Conversation: Identifiable, Codable, Equatable, ObservableObject {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.sessionId == rhs.sessionId
    }
    
    var id = UUID()
    @Published var name: String = "会话标题"
    var message: String {
        get {
            return messages.first?.content ?? ""
        }
    }
    var sessionId: String = ""
    @Published var messages: [Message] = []
    init(id: UUID = UUID(), name: String, sessionId: String, messages: [Message]) {
        self.id = id
        self.name = name
        self.sessionId = sessionId
        self.messages = messages
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId
        case messages
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        messages = try container.decode([Message].self, forKey: .messages)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(messages, forKey: .messages)
    }
}

enum MessageRole: Codable {
    case mine
    case chatGpt
}

class Message: Identifiable, Codable, ObservableObject{
    var id = UUID()
    var content: String = ""
    var role: MessageRole = .mine
    init(id: UUID = UUID(), content: String, role: MessageRole) {
        self.id = id
        self.content = content
        self.role = role
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case role
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        role = try container.decode(MessageRole.self, forKey: .role)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(role, forKey: .role)
    }
}

class ConversationData: Codable, ObservableObject {
    @Published var datas: [Conversation]
    
    init(datas: [Conversation]) {
        self.datas = datas
    }
    
    enum CodingKeys: String, CodingKey {
        case datas
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        datas = try container.decode([Conversation].self, forKey: .datas)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(datas, forKey: .datas)
    }
}

class ChatGPTManager {
    static let shared = ChatGPTManager()
    
    var allConversations: ConversationData = ConversationData(datas: [])
    private init() {
        allConversations = getDataFromUserDefaults()
    }
    
    /// 更新保存本地的会话
    func updateConversation(conversation: Conversation) {
        if allConversations.datas.contains(conversation) {
            //更新数组
            if let index = allConversations.datas.firstIndex(where: { $0.sessionId == conversation.sessionId }) {
                allConversations.datas[index] = conversation
            }
        }else {
            //添加数组
            if (conversation.messages.count > 0) {
                allConversations.datas.append(conversation)
            }
            
        }
        // 保存本地
        saveDataToUserDefaults(data: allConversations)
    }
    
    func createNewSessionId() -> String {
        let timestamp = String(Date().timeIntervalSince1970)
        return timestamp
    }
    
}

extension ChatGPTManager {
    /// 获取本地数据
    private func getDataFromUserDefaults() -> ConversationData {
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard
        if let savedCustomDict = defaults.object(forKey: "ChatGPTSessions_key") as? Data {
            if let loadedCustomDict = try? decoder.decode(ConversationData.self, from: savedCustomDict) {
                loadedCustomDict.datas.removeAll { con in
                    con.messages.count == 0
                }
                return loadedCustomDict
            }
        }
        return ConversationData(datas: [])
    }
    /// 保存本地数据
    private func saveDataToUserDefaults(data: ConversationData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "ChatGPTSessions_key")
        }
    }
}
