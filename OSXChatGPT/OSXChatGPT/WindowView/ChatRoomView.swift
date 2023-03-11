//
//  ChatRoomView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI

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
struct ChatRoomView: View {
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

