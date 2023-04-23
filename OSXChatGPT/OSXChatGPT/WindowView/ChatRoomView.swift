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
                ScrollViewReader { scrollView in
                    List {
                        ForEach(viewModel.messages, id: \.id) { message in
                            ChatRoomCellView(message: message).environmentObject(viewModel)
                                .id(message.id) // 添加唯一标识符
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                                .onAppear {
                                    if viewModel.messages.count > 1 {
                                        if viewModel.messages[1] == message && self.isOnAppear {
                                            //加载更多
                                            viewModel.fetchMoreMessage(sesstionId: conversation?.sesstionId ?? "")
                                        }
                                    }
                                }
                        }
                        
                        .padding(.bottom, 10)
                    }
                    .onChange(of: viewModel.changeMsgText) { _ in
                        withAnimation {
                            if let msgId = viewModel.messages.last?.id {
                                scrollView.scrollTo(msgId, anchor: .bottom)
                            }
                        }
                    }
                    
                    .onAppear {
                        // 将 ScrollViewProxy 存储在状态中
                        self.scrollView = scrollView
                    }
                }
                .frame(maxHeight: geometry.size.height) // 限制高度以便滚动
                .background(Color.clear)
            Divider()
            GeometryReader { toolBarGeometry in
                Spacer()
                ChatRoomToolBar().environmentObject(viewModel)
                    .frame(width: toolBarGeometry.size.width, height: toolBarGeometry.size.height)
                    .background(Color.clear)
                
            }.frame(height: 28)
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
            viewModel.checkGPT(sesstion: conversation)
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
    @Environment(\.colorScheme) private var colorScheme
    var gptBubbleColor: Color {
        switch colorScheme {
        case .dark:
            return Color.gray.opacity(0.1)
        default:
            return Color.white.opacity(0.9)
        }
    }
    var markdownTheme: MarkdownTheme {
        switch colorScheme {
        case .dark:
            return .wwdc17()
        default:
            return .sunset()
        }
        
    }
    var body: some View {
        HStack {
            if message.role != ChatGPTManager.shared.gptRoleString {
                Spacer()
                VStack {
                    Text(message.text ?? "")
                        .textSelection(.enabled)
                        .font(Font.system(size: 13, weight: .regular, design: .monospaced))
                        .lineSpacing(1.5)
                        .id(message.id)
                }.padding(12)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .contextMenu {
                        Button(action: {
                            viewModel.deleteMessage(message: message)
                        }) {
                            Text(Localization.deleteMessage.localized)
                        }
                    }

//                VStack {
//                    Image("User")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .padding(0)
//                    Spacer()
//                }
            } else {
//                VStack {
//                    Image("openAI_icon")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .padding(0)
//                    Spacer()
//                }
                if message.msgType == .waitingReply {
                    //等待chatGPT回复的动画
                    ThinkingAnimationView()
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                else {
//                    MarkdownView(message.textModel.array as? [MessageText] ?? [], theme: markdownTheme)//自定义
                    MarkdownContentView {
                        Markdown(message.text ?? "")
                            .padding(12)
                            .textSelection(.enabled)
                            .markdownCodeSyntaxHighlighter(.splash(theme: viewModel.codeTheme(scheme: colorScheme)))
                            .background(gptBubbleColor)
                            .cornerRadius(6)
                    }
                    .id(message.id)
                    .contextMenu {
                        Button(action: {
                            viewModel.deleteMessage(message: message)
                        }) {
                            Text(Localization.deleteMessage.localized)
                        }
                        Button(action: {
                            NSPasteboard.general.prepareForNewContents()
                            NSPasteboard.general.setString(message.text ?? "", forType: .string)
                        }) {
                            Text(Localization.copyMessage.localized)
                        }
                    }
                    if message.msgType == .fialMsg && viewModel.messages.last?.id == message.id {
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
        .padding(.trailing, (message.role == ChatGPTManager.shared.gptRoleString) ? 30 : 0)
        .padding(.leading, (message.role != ChatGPTManager.shared.gptRoleString) ? 30 : 0)
    }
}


