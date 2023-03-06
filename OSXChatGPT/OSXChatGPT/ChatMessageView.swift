//
//  ChatMessageView.swift
//  OSXChatGPT
//
//  Created by 陈连辰 on 2023/3/5.
//

import SwiftUI
import AppKit
/// main View
struct ContentView: View {
    
    @EnvironmentObject var chats: ConversationData
    @State private var searchText = ""
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    SearchBar(text: $searchText)
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: 200, minHeight: 40, idealHeight: 40, maxHeight: 40)
                        .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 0))
                    
                    NavigationLink(destination: ChatView(chat: Conversation(name: "New", sessionId: ChatGPTManager.shared.createNewSessionId(), messages: [])), isActive: $shouldNavigate) {
                        Button {
                            self.shouldNavigate = true
                        } label: {
                            Text("New")
                                .padding(5)
                            Spacer()
                        }.background(Color.clear)
                            
                        
                    }.frame(minWidth: 40, idealWidth: 50, maxWidth: 50, minHeight: 40, idealHeight: 40, maxHeight: 40)
//                        .background(.clear)
                        .padding(.init(top: 10, leading: 0, bottom: 0, trailing: 10))
                    
                }.frame(minHeight: 40, idealHeight: 40, maxHeight: 50)
                Divider()
                List(chats.datas.filter({ searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText) })) { chat in
                    NavigationLink(destination: ChatView(chat: chat)) {
                        ChatRow(chat: chat)
                    }
                }
                .listStyle(SidebarListStyle())
                .padding(.top, 1)
                
                Spacer()
            }
            .frame(minWidth: 250, idealWidth: 300, maxWidth: 300)
            
            Text("请选择一个会话")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
struct ChatRow: View {
    var chat: Conversation
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(chat.message)
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
/// 聊天框
struct ChatView: View {
    let chat: Conversation
    @State private var newMessageText = ""
    @State private var scrollView: ScrollViewProxy?
    @State private var scrollID = UUID()
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(alignment: .trailing, spacing: 8) {
                            ForEach(chat.messages) { message in
                                MessageView(message: message)
                                    .id(message.id) // 添加唯一标识符
                                    .padding(.trailing, 30)
                            }
                        }
                        .onChange(of: scrollID) { _ in
                            // 滚动到最后一条消息
                            scrollView.scrollTo(chat.messages.last?.id, anchor: .bottom)
                        }
                        .background(Color.clear)
                        .onAppear {
                            // 将 ScrollViewProxy 存储在状态中
                            self.scrollView = scrollView
                        }
                    }
                    .background(Color.clear)
                    .onAppear {
                        // 将 ScrollView 存储在状态中
                        self.scrollView = scrollView
                    }
                    .onChange(of: chat.messages.count) { _ in
                        // 每次添加新消息时，更新 ID 以便滚动
                        self.scrollID = UUID()
                    }
                }
                .frame(maxHeight: geometry.size.height) // 限制高度以便滚动
            }
            Divider()
            HStack {
//                TextField("Type a message...", text: $newMessageText, onCommit: {
//                    sendMessage(scrollView: scrollView)
//                })
//                .textFieldStyle(PlainTextFieldStyle())
//                .lineLimit(30)
                GeometryReader { geometry in
                    if #available(macOS 13.0, *) {
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
                    } else {
                        // Fallback on earlier versions
                    }
                        
                }
            }
            .padding(0)
            .frame(maxHeight: 200)
        }
        .onAppear {
            print("View appeared!")
        }
        .onDisappear {
            print("View disappeared!")
            ChatGPTManager.shared.updateConversation(conversation: chat)
        }
    }
    
    private func sendMessage(scrollView: ScrollViewProxy?) {
        guard !newMessageText.isEmpty else { return }
        
        let temp = NSMutableString(string: newMessageText)
        let replaceStr = temp.replacingOccurrences(of: "\n", with: "")
        chat.messages.append(Message(content: replaceStr, role: .mine))
        if chat.messages.count == 1 {
        }
        ChatGPTManager.shared.updateConversation(conversation: chat)//更新侧边栏列表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            newMessageText = ""
            scrollView?.scrollTo(chat.messages.last?.id, anchor: .bottom)
        }
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role == .mine {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            } else {
                Text(message.content)
                    .padding(12)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                Spacer()
            }
        }
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

