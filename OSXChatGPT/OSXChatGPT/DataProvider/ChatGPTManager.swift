//
//  ChatGPTManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import Foundation


class ChatGPTManager {
    static let shared = ChatGPTManager()
    private var messagesDict: [String:[Message]] = [:]
    private let httpClient: HTTPClient = HTTPClient()
    private let apiKey : String = myApiKey
    let gptRoleString: String = "assistant"
    private init() {
        
    }
}

/// Chat GTP
extension ChatGPTManager {
    /// 提问
    func askChatGPT(messages: [Message], complete:(([String: Any]?, String?) -> ())?) {
        var arr: [Message] = messages
        //来回两次算一次对话，上下文传最多传5次对话
        arr = checkMaxAskMsgCount(maxCount: 10, messages: arr)
        var temp: [[String: String]] = []
        arr.forEach { msg in
            temp.append(["role": msg.role ?? "user", "content": msg.text ?? ""])
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
    
    private func checkMaxAskMsgCount(maxCount: Int, messages: [Message]) -> [Message] {
        var msg = messages
        if msg.count > maxCount {
            msg.remove(at: 0)
            return checkMaxAskMsgCount(maxCount: maxCount, messages: msg)
        }else {
            return msg
        }
    }
    
}
