//
//  ChatGPTManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import Foundation

private let OSXChatGPTKEY = "OSXChatGPT_apiKey_key"
struct ChatGPTResponse {
    var request: ChatGPTRequest
    var state: State
    var text: String
    enum State {
        case replyStart
        case replying
        case replyFinish
        case replyFial
    }
    
}
struct ChatGPTRequest {
    let model: ChatGPTModel
    let temperature: Double = 0.5
    let messages: [Message]
    let answerType: ChatGPTAnswerType//是否流式回答
    let contextCount: ChatGPTContext
    let systemMsg: String?//修饰语
    
//    static let completions = URL(string: "https://api.openai.com/v1/completions")!
//    static let images = URL(string: "https://api.openai.com/v1/images/generations")!
//    static let embeddings = URL(string: "https://api.openai.com/v1/embeddings")!
//    static let chats = URL(string: "https://api.openai.com/v1/chat/completions")!
    var url: URL {
        switch model {
        case .textDavinci001, .textDavinci002, .textDavinci003:
            return URL(string: "https://api.openai.com/v1/completions")!
        case .curie, .embeddingAda, .ada, .searchBabbadgeDoc, .searchBabbageQuery, .babbage:
            return URL(string: "https://api.openai.com/v1/embeddings")!
        //以上未验证
        case .gpt35turbo,.gpt35turbo0301:
            return URL(string: "https://api.openai.com/v1/chat/completions")!
        default:
            return URL(string: "https://api.openai.com/v1/chat/completions")!
            
        }
    }
    let apiKey: String
    var headers: [String: String] {
        let dict = ["Content-Type": "application/json",
                    "Authorization": "Bearer \(apiKey)"]
        return dict
    }
    
    var msg: [[String: String]] {
        get {
            let arr = messages.suffix(contextCount.valyeInt * 2 + 1)
            var temp: [[String: String]] = []
            arr.forEach { msg in
                if msg.type != 1 {
                    //移除错误的回复，不误导gpt
                    temp.append(["role": msg.role ?? "user", "content": msg.text ?? ""])
                }
            }
            if let system = systemMsg {
                let sys = ["role":"system", "content":system]
                temp.insert(sys, at: 0)
            }
            return temp
        }
    }
    var parameters: [String: Any] {
        get {
            let par = [
                "model": model.value,
                "messages": msg,
                "stream": answerType.valueBool
            ] as [String : Any]
            return par
        }
    }
}
enum ChatGPTAnswerType: CaseIterable, ToolBarMenuProtocol {
    var value: String {
        switch self {
        case .stream:
            return "流式"
        case .oneTime:
            return "单式"
        }
    }
    case stream
    case oneTime
    var valueBool: Bool {
        return self == .stream ? true : false
    }
    static var allCases: [ChatGPTAnswerType] {
        return [.stream, .oneTime]
    }
}
enum ChatGPTContext: CaseIterable, ToolBarMenuProtocol {
    case context0
    case context1
    case context2
    case context3
    case context4
    case context5
    case context6
    case context7
    case context8
    case context9
    case context10
    case infinite
    
    var value: String {
        switch self {
        case .context0:
            return "0"
        case .context1:
            return "1"
        case .context2:
            return "2"
        case .context3:
            return "3"
        case .context4:
            return "4"
        case .context5:
            return "5"
        case .context6:
            return "6"
        case .context7:
            return "7"
        case .context8:
            return "8"
        case .context9:
            return "9"
        case .context10:
            return "10"
        case .infinite:
            return "999"
        }
    }
    var valyeInt: Int {
        return Int(self.value) ?? 1
    }
    static var allCases: [ChatGPTContext] {
        return [.context0,
                .context1,
                .context2,
                .context3,
                .context4,
                .context5,
                .context6,
                .context7,
                .context8,
                .context9,
                .context10,
                .infinite]
    }
}
enum ChatGPTModel: CaseIterable, ToolBarMenuProtocol {
    var value: String {
        switch self {
        case .textDavinci001:
            return "text-davinci-001"
        case .textDavinci002:
            return "text-davinci-002"
        case .textDavinci003:
            return "text-davinci-003"
        case .curie:
            return "text-curie-001"
        case .babbage:
            return "text-babbage-001"
        case .searchBabbadgeDoc:
            return "text-search-babbage-doc-001"
        case .searchBabbageQuery:
            return "text-search-babbage-query-001"
        case .ada:
            return "text-ada-001"
        case .embeddingAda:
            return "text-embedding-ada-002"
            
        case .gpt35turbo:
            return "gpt-3.5-turbo"
        case .gpt35turbo0301:
            return "gpt-3.5-turbo-0301"
            
        case .gpt4:
            return "gpt-4"
        case .gpt40134:
            return "gpt-4-0314"
        case .gpt432k:
            return "gpt-4-32k"
        case .gpt432k0314:
            return "gpt-4-32k-0314"
        }
    }
    
    case textDavinci001
    case textDavinci002
    case textDavinci003
    case curie
    case babbage
    case searchBabbadgeDoc
    case searchBabbageQuery
    case ada
    case embeddingAda
    //以上旧api，需要兼容
    
    case gpt35turbo
    case gpt35turbo0301
    
    case gpt4
    case gpt40134
    case gpt432k
    case gpt432k0314
    
    static var allCases: [ChatGPTModel] {
        return [.gpt35turbo, .gpt35turbo0301, .gpt4, .gpt40134, .gpt432k, .gpt432k0314]
    }
}



class ChatGPTManager {
    static let shared = ChatGPTManager()
    private var messagesDict: [String:[Message]] = [:]
    private let httpClient: HTTPClient = HTTPClient()
    private lazy var apiKey : String = {
        let key = UserDefaults.standard.value(forKey: OSXChatGPTKEY) as? String
        return key ?? ""
    }()
    @Published var chatGPTSpeaking: Bool = false
    var askContextCount: ChatGPTContext = .context3
    let gptRoleString: String = "assistant"
    var tempMessagePool = MessagePool()
    
    var model: ChatGPTModel = .gpt35turbo
    var answerType: ChatGPTAnswerType = .stream
    private init() {
        let _  = getMaskApiKey()
    }
    
}
// MARK: - 一些接口
extension ChatGPTManager {
    func updateApiKey(apiKey: String) {
//        httpClient.testSha()
        
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
}
// MARK: - Chat GTP 提问
extension ChatGPTManager {
    func stopResponse() {
        httpClient.cancelStream()
        self.chatGPTSpeaking = false
        
        
    }
    func askChatGPTStream(messages: [Message], prompt: String?, complete:((ChatGPTResponse) -> ())?) {
        if chatGPTSpeaking == true {
            return
        }
        chatGPTSpeaking = true
        let request = ChatGPTRequest(model: model, messages: messages, answerType: answerType, contextCount: askContextCount, systemMsg: prompt, apiKey: apiKey)
        
        Task {
            do {
                let stream = try await httpClient.postStream(chatRequest: request)
                let res = ChatGPTResponse(request: request ,state: .replyStart, text: "")
                await tempMessagePool.reset()
                if self.chatGPTSpeaking == false {
                    return
                }
                DispatchQueue.main.async {
                    complete?(res)
                }
                var newMsg: String = ""
                for try await line in stream {
                    await tempMessagePool.append(line: line)
                    let newMessage = await tempMessagePool.message
                    print("回复：\(newMessage)")
                    newMsg += newMessage
                    let res = ChatGPTResponse(request: request ,state: .replying, text: newMessage)
                    DispatchQueue.main.async {
                        complete?(res)
                    }
                }
                let re = ChatGPTResponse(request: request ,state: .replyFinish, text: newMsg)
                await tempMessagePool.reset()
                DispatchQueue.main.async {
                    self.chatGPTSpeaking = false
                    complete?(re)
                }
            }catch let err {
                await tempMessagePool.reset()
                if let error = err as? HTTPError {
                    let res = ChatGPTResponse(request: request ,state: .replyFial, text: error.message)
                    DispatchQueue.main.async {
                        self.chatGPTSpeaking = false
                        complete?(res)
                    }
                }
                
            }
        }
    }
    
    /// 提问
    func askChatGPT(messages: [Message], complete:(([String: Any]?, String?) -> ())?) {
        //来回两次算一次对话，上下文传最多传的对话
        let arr = messages.suffix(askContextCount.valyeInt * 2 + 1)
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


actor MessagePool {
    var message: String = """
    """

    func append(line: String) {
        message += line
    }

    func reset() {
        message.removeAll()
    }
}
