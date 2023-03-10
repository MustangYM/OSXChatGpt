//
//  ChatMessageView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI
import AppKit
/// main View
struct ContentView: View {
    var body: some View {
        NavigationView {
            SessionsView()
            UserInitializeView()
        }
    }
}
/// 搜索框
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("搜索", text: $text)
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .padding(.leading, 15)
                .background(.clear)
                .cornerRadius(5)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                            .cornerRadius(5)
                        
                        Spacer()
                    }.background(.clear)
                )
                .padding(.horizontal, 4)
        }
    }
}
/// 左边会话列表
struct ChatRowContent: View {
    @State var chat: Conversation
    var body: some View {
        MyView(chat: chat)
            .frame(minHeight: 50, idealHeight: 50, maxHeight: 50)
    }
}
/// 左边会话列表
struct ChatRow: View {
    @State var chat: Conversation
    var body: some View {
        HStack {
            Image("openAI_icon")
                .resizable()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading) {
                Text(chat.lastMessage?.text ?? "newChat")
                    .font(.headline)

                //                Text(chat.message)
                //                    .font(.subheadline)
                //                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
struct MyView: NSViewRepresentable {
    @State var chat: Conversation
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update view properties and state here.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: MyView
        
        init(_ parent: MyView) {
            self.parent = parent
            super.init()
        }
        
        @objc func handleRightClick(_ sender: NSClickGestureRecognizer) {
            if sender.state == .ended {
                print("Right mouse button clicked!")
            }
        }
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 3
        let swiftUIView = ChatRow(chat: chat)
            .frame(width: 300, height: 50)
        let hostingView = NSHostingView(rootView: swiftUIView)
        view.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        let gestureRecognizer = NSClickGestureRecognizer(target: context.coordinator,
                                                          action: #selector(Coordinator.handleRightClick(_:)))
        gestureRecognizer.buttonMask = 0x2 // 双击事件
        view.addGestureRecognizer(gestureRecognizer)
        
        return view
    }
}
struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role != ChatGPTManager.shared.gptRoleString {
                Spacer()
                Text(message.text ?? "")
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            } else {
                Text(message.text ?? "")
                    .padding(12)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                Spacer()
            }
        }.padding(.trailing, (message.role == ChatGPTManager.shared.gptRoleString) ? 70 : 0)
        .padding(.leading, (message.role != ChatGPTManager.shared.gptRoleString) ? 70 : 0)
    }
}

/// 聊天框
struct ChatView: View {
    var sesstionId: String
    @EnvironmentObject var viewModel: ViewModel
    @State private var newMessageText = ""
    @State private var scrollView: ScrollViewProxy?
    @State private var scrollID = UUID()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(alignment: .trailing, spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageView(message: message)
                                    .id(message.id) // 添加唯一标识符
                                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            }
                        }
                        .onChange(of: scrollID) { _ in
                            // 滚动到最后一条消息
                            scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                        .background(Color.clear)
                        .onAppear {
                            // 将 ScrollViewProxy 存储在状态中
                            self.scrollView = scrollView
                        }
                    }
                    .background(Color.clear)
                    .onAppear {
                        viewModel.fetchMessage(sesstionId: sesstionId)
                        // 将 ScrollView 存储在状态中
                        self.scrollView = scrollView
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // 每次添加新消息时，更新 ID 以便滚动
                        self.scrollID = UUID()
                    }
                }
                .frame(maxHeight: geometry.size.height) // 限制高度以便滚动
            }
            Divider()
            HStack {
                GeometryReader { geometry in
                    TextEditor(text: $newMessageText)
                        .font(.title3)
                        .lineSpacing(5)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        .cornerRadius(10)
                        .frame(maxHeight: geometry.size.height)
                        .onChange(of: newMessageText) { _ in
                            if newMessageText.contains("\n") {
                                sendMessage(scrollView: scrollView)
                            }
                        }
                }
            }
            .padding(0)
            .frame(maxHeight: 200)
        }
        .onAppear {
            print("View appeared!")
            viewModel.fetchMessage(sesstionId: sesstionId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                
            }
        }
        .onDisappear {
            print("View disappeared!")
        }
    }
    
    private func sendMessage(scrollView: ScrollViewProxy?) {
        guard !newMessageText.isEmpty else { return }
        
        let temp = NSMutableString(string: newMessageText)
        let replaceStr = temp.replacingOccurrences(of: "\n", with: "")
        viewModel.addNewMessage(sesstionId: sesstionId, text: replaceStr, role: "user") {
            scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
        }
        if viewModel.messages.count == 1 {
            //有点问题
            viewModel.fetchConversations()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            newMessageText = ""
            scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            
        }
    }
}



struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

