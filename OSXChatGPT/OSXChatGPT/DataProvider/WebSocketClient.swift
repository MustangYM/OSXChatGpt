//
//  aaaaa.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/22.
//

import Foundation

//import Starscream
//
//class EngineObj: Engine {
//    weak var delegate: Starscream.EngineDelegate?
//    func register(delegate: Starscream.EngineDelegate) {
//        self.delegate = delegate
//        print("register")
//    }
//
//    func start(request: URLRequest) {
//        print("start")
//    }
//
//    func stop(closeCode: UInt16) {
//        print("stop")
//    }
//
//    func forceStop() {
//        print("forceStop")
//    }
//
//    func write(data: Data, opcode: Starscream.FrameOpCode, completion: (() -> ())?) {
//        print("write")
//    }
//
//    func write(string: String, completion: (() -> ())?) {
//        print("write")
//    }
//
//
//}
//
//class WebSocketClient:NSObject, WebSocketDelegate {
//
//
//    var socket: WebSocket?
//    var receivedData = Data()
////    let eng = WSEngine(transport: <#Transport#>)
//
//    // 创建 WebSocketClient 实例并连接到 OpenAI API
//    static let client = WebSocketClient()
//
//
////    func start() {
//////        client.connect(apiKey: "\(ChatGPTManager.shared.getApiKey())")
////
////        // 等待 WebSocket 连接
////        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.0))
////
////        // 向 OpenAI API 发送请求
////        client.sendMessage(prompt: "我想让一张图片和文字匹配")
////
////        // 循环等待响应数据
////        RunLoop.main.run()
////    }
//
//    func connect() {
//        // 建立 WebSocket 请求
//        let request = URLRequest(url: URL(string: "wss://api.openai.com/v1/websockets/chat")!)
//        var headers = [String: String]()
//        headers["Authorization"] = "Bearer \(ChatGPTManager.shared.getApiKey())"
//        // 创建 WebSocket 连接
//        socket = WebSocket(request: request)
////        socket = WebSocket(request: request, headers: headers)
//        socket?.delegate = self
//
//        // 开始连接
//        socket?.connect()
//    }
//
//    func sendMessage(prompt: String) {
//        // 发送请求参数
//        let parameters: [String: Any] = [
//            "model": "text-davinci-002",
//            "prompt": prompt,
//            "temperature": 0.7,
//            "max_tokens": 50
//        ]
//        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
//
//        // 发送 WebSocket 消息
//        let jsonString = String(data: jsonData, encoding: .utf8)!
//        socket?.write(string: jsonString)
//    }
//
//    func websocketDidConnect(socket: WebSocketClient) {
//        print("WebSocket 连接成功")
//    }
//
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        print("WebSocket 连接断开: \(error?.localizedDescription ?? "?")")
//    }
//
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        print("收到 WebSocket 消息: \(text)")
//
//        // 将收到的消息累加到已接收数据中
//        receivedData.append(text.data(using: .utf8)!)
//
//        // 尝试解析已接收数据
//        if let response = try? JSONSerialization.jsonObject(with: receivedData, options: .allowFragments) {
//            print("接收到响应数据: \(response)")
//
//            // 重置已接收数据的缓存
//            receivedData = Data()
//        }
//    }
//
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        print("收到 WebSocket 数据: \(data)")
//    }
//    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
//        print("收到 didReceive 数据: \(client)")
//        switch event {
//
//        case .connected(_):
//            print("收到 didReceive connected")
//        case .disconnected(_, _):
//            print("收到 didReceive disconnected")
//        case .text(_):
//            print("收到 didReceive text")
//        case .binary(_):
//            print("收到 didReceive binary")
//        case .pong(_):
//            print("收到 didReceive pong")
//        case .ping(_):
//            print("收到 didReceive ping")
//        case .error(let err):
//            print("收到 didReceive error\(err)")
//        case .viabilityChanged(_):
//            print("收到 didReceive viabilityChanged")
//        case .reconnectSuggested(_):
//            print("收到 didReceive reconnectSuggested")
//        case .cancelled:
//            print("收到 didReceive cancelled")
//        }
//    }
//}

