//
//  ChatRoomCellView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI
import AppKit
import MarkdownUI


/// 聊天框
struct ChatRoomView: View {
    var conversation: Conversation?
    @EnvironmentObject var viewModel: ViewModel
    @State private var newMessageText = ""
    @State private var lastMessageText = ""
    @State private var scrollView: ScrollViewProxy?
    @State private var scrollID = UUID()
    
    @State private var isOnAppear: Bool = false
    @State var apiKey: String = ChatGPTManager.shared.getMaskApiKey()
    @State var openArgumentSeet: Bool = false
    
    @State private var inputViewHeight: CGFloat = 200
    

    
    init(conversation: Conversation?) {
        self.conversation = conversation
        
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack(alignment: .trailing, spacing: 8) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            ChatRoomCellView(message: message).environmentObject(viewModel)
                                .id(message.id) // 添加唯一标识符
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                                .onAppear {
                                    if viewModel.messages.count > 1 {
                                        if viewModel.messages[1] == message && self.isOnAppear {
                                            //加载更多
                                            viewModel.fetchMoreMessage(sesstionId: conversation?.sesstionId ?? "")
                                        }
                                    }
                                }
                        }
                    }.padding(.bottom, 25)
                    .onChange(of: viewModel.changeMsgText) { _ in
                        withAnimation {
                            if let msgId = viewModel.messages.last?.id {
                                scrollView.scrollTo(msgId, anchor: .bottom)
                            }
                        }
                    }
                    .background(Color.clear)
                    .onAppear {
                        // 将 ScrollViewProxy 存储在状态中
                        self.scrollView = scrollView
                    }
                }
                .background(Color.clear)
                
                
            }
            .frame(maxHeight: geometry.size.height - inputViewHeight) // 限制高度以便滚动
            Divider()
            GeometryReader { toolBarGeometry in
                Spacer()
                ChatRoomToolBar().environmentObject(viewModel)
                    .frame(width: toolBarGeometry.size.width, height: toolBarGeometry.size.height)
                    .background(Color.clear)
                
            }.frame(height: 28)
//            Divider()
            ChatRoomInputView(inputViewHeight: $inputViewHeight)
        }
        }
        .padding(.top, 1)
        
            
        
        .onAppear {
            print("View appeared!")
            newMessageText = conversation?.lastInputText ?? ""
            KeyboardMonitor.shared.startMonitorPasteboard()
            KeyboardMonitor.shared.startMonitorShiftKey()
            viewModel.currentConversation = conversation
            viewModel.fetchFirstMessage(sesstionId: conversation?.sesstionId ?? "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    self.isOnAppear = true
                }
            }
            
            let _ = SystemManager.shared//获取系统用户名以及版本号
            ServerManager.shared.checkToken()//获取最新teton
        }
        .onDisappear {
            print("View disappeared!")
            self.isOnAppear = false
            conversation?.lastInputText = newMessageText
            
        }
        .sheet(isPresented: $openArgumentSeet) {
            EnterAPIView(apiKey: $apiKey)
        }
        

    }


}


struct ChatRoomCellView: View {
    let message: Message
    @EnvironmentObject var viewModel: ViewModel
    private let theme: Theme = .basic
    var body: some View {
        HStack {
            if message.role != ChatGPTManager.shared.gptRoleString {
                Spacer()
                VStack {
                    Text(message.text ?? "")
                        .textSelection(.enabled)
                        .id(message.id)
                }.padding(12)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .contextMenu {
                        Button(action: {
                            viewModel.deleteMessage(message: message)
                        }) {
                            Text("删除消息")
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
                if message.type == 1 {
                    //等待chatGPT回复的动画
                    ThinkingAnimationView()
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                else {
                    MarkdownView {
                        Markdown(message.text ?? "")
                            .padding(12)
                            .textSelection(.enabled)
                            .markdownCodeSyntaxHighlighter(.splash(theme: viewModel.theme))
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(6)
                    }.id(message.id)
                    .contextMenu {
                        Button(action: {
                            viewModel.deleteMessage(message: message)
                        }) {
                            Text("删除消息")
                        }
                        Button(action: {
                            NSPasteboard.general.prepareForNewContents()
                            NSPasteboard.general.setString(message.text ?? "", forType: .string)
                        }) {
                            Text("复制消息")
                        }
                    }
                    if message.type == 2 && viewModel.messages.last?.id == message.id {
                        Button {
                            viewModel.resendMessage(sesstionId: viewModel.currentConversation?.sesstionId ?? "", prompt: viewModel.currentConversation?.prompt?.prompt)
                        } label: {
                            Image("retry")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .frame(width: 30, height: 30)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                    
                Spacer()
            }
        }
        .padding(.trailing, (message.role == ChatGPTManager.shared.gptRoleString) ? 70 : 0)
        .padding(.leading, (message.role != ChatGPTManager.shared.gptRoleString) ? 70 : 0)
    }
}


