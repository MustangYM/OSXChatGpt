//
//  ChatRoomCellView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI


/// 聊天框
struct ChatRoomView: View {
    let conversation: Conversation
    var isNewConversation: Bool = false
    @EnvironmentObject var viewModel: ViewModel
    @State private var newMessageText = ""
    @State private var scrollView: ScrollViewProxy?
    @State private var scrollID = UUID()
    
    init(conversation: Conversation, isNewConversation: Bool=false) {
        self.conversation = conversation
        self.isNewConversation = isNewConversation
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(alignment: .trailing, spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                ChatRoomCellView(message: message)
                                    .id(message.id) // 添加唯一标识符
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                            }
                        }
                        .onChange(of: scrollID) { _ in
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
//                        viewModel.fetchMessage(sesstionId: sesstionId)
                        // 将 ScrollView 存储在状态中
                        self.scrollView = scrollView
                        
                    }
                    .onDisappear {
                        
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // 每次添加新消息时，更新 ID 以便滚动
                        self.scrollID = UUID()
                    }
                }
                .frame(maxHeight: geometry.size.height) // 限制高度以便滚动
            }
            .padding(.top, 1)
            Divider()
            HStack {
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
                        TextEditor(text: $newMessageText)
                            .font(.title3)
                            .lineSpacing(5)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(10)
                            .frame(maxHeight: geometry.size.height)
                            .onChange(of: newMessageText) { _ in
                                if newMessageText.contains("\n") {
                                    sendMessage(scrollView: scrollView)
                                }
                            }
                    }
                }
            }
            .padding(0)
            .frame(maxHeight: 200)
        }
        .onAppear {
            print("View appeared!")
            //**全局监控一下当前conversation
            Config.shared.CurrentSession = conversation.sesstionId
            viewModel.fetchMessage(sesstionId: conversation.sesstionId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            }
        }
        .onDisappear {
            print("View disappeared!")
        }.navigationTitle(conversation.remark ?? conversation.lastMessage?.text ?? "New Chat")
    }
    
    
    private func sendMessage(scrollView: ScrollViewProxy?) {
        guard !newMessageText.isEmpty else { return }
        let temp = NSMutableString(string: newMessageText)
        let replaceStr = temp.replacingOccurrences(of: "\n", with: "")
        viewModel.addNewMessage(sesstionId: Config.shared.CurrentSession, text: replaceStr, role: "user") {
            scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            conversation.lastMessage = viewModel.messages.last
            conversation.updateData = Date()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            //清空
            newMessageText = ""
            scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
        }
    }
}



struct ChatRoomCellView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role != ChatGPTManager.shared.gptRoleString {
                Spacer()
                VStack {
                    Text(message.text ?? "")
                }.padding(12)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .contextMenu {
                        Button(action: {
                            NSPasteboard.general.prepareForNewContents()
                            NSPasteboard.general.setString(message.text ?? "", forType: .string)
                        }) {
                            Text("Copy")
                            Image(systemName: "doc.on.doc.fill")
                        }
                    }
                
                    
                VStack {
                    Image("User")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(0)
                    Spacer()
                }
            } else {
                VStack {
                    Image("openAI_icon")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(0)
                    Spacer()
                }
                if message.hasCode {
                    VStack {
                        ForEach(message.textArray, id: \.self) { model in
                            ChatRoomCellTextView(textModel: model)
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    
                }else {
                    Text(message.text ?? "")
                        .padding(12)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .contextMenu {
                            Button(action: {
                                NSPasteboard.general.prepareForNewContents()
                                NSPasteboard.general.setString(message.text ?? "", forType: .string)
                            }) {
                                Text("Copy")
                                Image(systemName: "doc.on.doc.fill")
                            }
                        }
                }
                    
                Spacer()
            }
        }
        .padding(.trailing, (message.role == ChatGPTManager.shared.gptRoleString) ? 70 : 0)
        .padding(.leading, (message.role != ChatGPTManager.shared.gptRoleString) ? 70 : 0)
    }
}

struct ChatRoomCellTextView: View {
    let textModel: MessageTextModel
    var body: some View {
        if textModel.type == .text {
            HStack {
                Text(textModel.text)
                    .foregroundColor(.white)
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
            .contextMenu {
                Button(action: {
                    NSPasteboard.general.prepareForNewContents()
                    NSPasteboard.general.setString(textModel.text, forType: .string)
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc.fill")
                }
            }
        }else {
            VStack {
                HStack {
                    Text(textModel.headText)
                        .foregroundColor(.white)
                        .frame(height: 20)
                        .padding(.leading, 10)
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Text("Copy")
                        Image(systemName: "doc.on.doc.fill")
                    }
                }.background(Color.white.opacity(0.4))
                    .padding(0)
                    .padding(.leading, 0)
                HStack {
                    Text(textModel.text)
                        .foregroundColor(NSColor(r: 0, g: 195, b: 135).toColor())
                        .padding(.top, 0)
                        .padding(.leading, 10)
                    Spacer()
                }
                
            }.padding(.leading, 0)
                .padding(.top, 0)
                .background(Color.black.opacity(0.7))
            .cornerRadius(5)
            .frame(minWidth: 20)
            .contextMenu {
                Button(action: {
                    NSPasteboard.general.prepareForNewContents()
                    NSPasteboard.general.setString(textModel.text, forType: .string)
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc.fill")
                }
            }
        }
    }
}
