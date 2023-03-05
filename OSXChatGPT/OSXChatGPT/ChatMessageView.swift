//
//  ChatMessageView.swift
//  OSXChatGPT
//
//  Created by 陈连辰 on 2023/3/5.
//

import SwiftUI
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
                    
                    
                    NavigationLink(destination: ChatView(chat: Conversation(name: "新会话", sessionId: ChatGPTManager.shared.createNewSessionId(), messages: [])), isActive: $shouldNavigate) {
                        Button {
                            self.shouldNavigate = true
                        } label: {
                            Text("新会话")
                                .padding(0)
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
                .background(.gray)
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
//    @State var messages: [Message] = self.chat.messages
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chat.messages) { message in
                        MessageView(message: message)
                    }
                }
            }
            Divider()
            HStack {
                TextField("Type a message...", text: $newMessageText)
                    .textFieldStyle(PlainTextFieldStyle())
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
            .padding(8)
        }
        
        .onAppear {
            print("View appeared!")
        }
        .onDisappear {
            print("View disappeared!")
            ChatGPTManager.shared.updateConversation(conversation: chat)
        }
    }
    
    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        chat.messages.append(Message(content: newMessageText, role: .mine))
        newMessageText = ""
        if chat.messages.count == 1 {
        }
        ChatGPTManager.shared.updateConversation(conversation: chat)//更新侧边栏列表
        
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
                    .cornerRadius(16)
            } else {
                Text(message.content)
                    .padding(12)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(16)
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

