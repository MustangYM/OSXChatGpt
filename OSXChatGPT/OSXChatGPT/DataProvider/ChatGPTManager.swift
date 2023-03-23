//
//  ChatGPTManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import Foundation

private let OSXChatGPTKEY = "OSXChatGPT_apiKey_key"

class ChatGPTManager {
    static let shared = ChatGPTManager()
    private var messagesDict: [String:[Message]] = [:]
    private let httpClient: HTTPClient = HTTPClient()
    private lazy var apiKey : String = {
        let key = UserDefaults.standard.value(forKey: OSXChatGPTKEY) as? String
        return key ?? ""
    }()
    private var askContextCount: Int = 3
    let gptRoleString: String = "assistant"
    private init() {
        let _  = getMaskApiKey()
    }
    
}
// MARK: - 一些接口
extension ChatGPTManager {
    func updateApiKey(apiKey: String) {
        if apiKey.contains("********") {
            //没有修改
            return
        }
        self.apiKey = apiKey
        UserDefaults.standard.set(apiKey, forKey: OSXChatGPTKEY)
    }
    func getApiKey() -> String {
        let key = String(self.apiKey)
        return key
        
    }
    func getMaskApiKey() -> String {
        var key = String(self.apiKey)
        if key.count < 10 {
            return ""
        }
        maskString(&key, startIndex: 4, endIndex: key.count - 4)
        return key
    }
    /// 更新提问GPT的上下文数量（来回算一次）
    func updateContextCount(count: Int) {
        askContextCount = count
        if askContextCount <= 0 {
            askContextCount = 1
        }
    }
    /// 获取当前上下文数量（来回算一次）
    func getContextCount() -> Int {
        return askContextCount
    }
}
// MARK: - Chat GTP 提问
extension ChatGPTManager {
    /// 提问
    func askChatGPT(messages: [Message], complete:(([String: Any]?, String?) -> ())?) {
        //来回两次算一次对话，上下文传最多传的对话
        let arr = messages.suffix(askContextCount * 2 + 1)
        var temp: [[String: String]] = []
        arr.forEach { msg in
            if msg.type != 1 {
                //移除错误的回复，不误导gpt
                temp.append(["role": msg.role ?? "user", "content": msg.text ?? ""])
            }
        }
        let parameters = [
            "model": "gpt-3.5-turbo-0301",
            "messages": temp
        ] as [String : Any]
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            complete?(nil, "URL无效")
            return
        }
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        httpClient.post(url: url, headers: headers, parameters: parameters) { data, error, resCode in
            if let err = error {
                complete?(nil, err.domain)
                return
            }else if let da = data {
                guard let json = try? JSONSerialization.jsonObject(with: da) as? [String: Any] else {
                    DispatchQueue.main.async {
                        complete?(nil, "无效数据")
                    }
                    return
                }
                complete?(json, nil)
            }else {
                complete?(nil, "无效数据")
            }
        }
    }
    
}

extension ChatGPTManager {
    private func maskString(_ string: inout String, startIndex: Int, endIndex: Int, maskCharacter: Character = "*") {
        guard startIndex < endIndex else { return }
        let range = string.index(string.startIndex, offsetBy: startIndex) ..< string.index(string.startIndex, offsetBy: endIndex)
        let replacement = String(repeating: maskCharacter, count: endIndex - startIndex)
        string.replaceSubrange(range, with: replacement)
    }
}
