//
//  ChatRoomCellView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI
import AppKit

//低于macOS13输入框的背景色
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}
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
    
    init(conversation: Conversation?) {
        self.conversation = conversation
        
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { scrollView in
                        LazyVStack(alignment: .trailing, spacing: 8) {
                            ForEach(viewModel.messages) { message in
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
                        }
                        .onChange(of: scrollID) { _ in
                            scrollView.scrollTo(scrollID, anchor: .bottom)
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
                        self.scrollID = viewModel.messages.last?.id ?? UUID()
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
//                            .scrollContentBackground(.hidden)
                            .cornerRadius(10)
                            .frame(maxHeight: geometry.size.height)
                            .onChange(of: newMessageText) { newValue in
                                onTextViewChange(newValue)
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
                            .onChange(of: newMessageText) { newValue in
                                onTextViewChange(newValue)
                            }
                    }
                }
            }
            .padding(0)
            .frame(maxHeight: 200)
        }
        
        .onAppear {
            print("View appeared!")
            
            if apiKey.count < 10 {
                
            }
            
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
        }
        .onDisappear {
            print("View disappeared!")
            self.isOnAppear = false
            
        }
        .sheet(isPresented: $openArgumentSeet) {
            EnterAPIView(apiKey: $apiKey)
        }
        

    }

    private func compareText(newText: String, lastText: String) -> String {
        var newValue = String(newText)
        var lastValue = String(lastText)
        //比较两个字符串，找出新输入的那个字符
        newText.forEach { chart in
            if let index = newValue.firstIndex(of: chart) {
                if let idx = lastValue.firstIndex(of: chart) {
                    newValue.remove(at: index)
                    lastValue.remove(at: idx)
                }
            }
        }
        return newValue
    }
    
    private func onTextViewChange(_ newValue: String) {
        
        if (KeyboardMonitor.shared.shiftKeyPressed) {
            //按下shift
        }else if newMessageText.count < lastMessageText.count {
            //删除操作
        }else if newMessageText.count - 1 == lastMessageText.count {
            //在中间任意地方按下空格键发送
            let charts = compareText(newText: newMessageText, lastText: lastMessageText)
            if charts == "\n" {
                if KeyboardMonitor.shared.currentPasteboardText == newMessageText {
                    //复制进来的，不发送
                }else {
                    //输入的是空格，则发送
                    sendMessage(scrollView: scrollView, text: lastMessageText)
                }
            }
        }
        lastMessageText = newMessageText
    }
    
    private func sendMessage(scrollView: ScrollViewProxy?, text: String) {
        guard !newMessageText.isEmpty else { return }
        let msg = String(newMessageText.dropLast())
        let replaceStr = msg.replacingOccurrences(of: " ", with: "")
        if replaceStr.count == 0 {
            newMessageText = ""
            return
        }else if replaceStr.contains("\n") {
            let repl = replaceStr.replacingOccurrences(of: "\n", with: "")
            if repl.count == 0 {
                newMessageText = ""
                return
            }
        }
        viewModel.addNewMessage(sesstionId: viewModel.currentConversation?.sesstionId ?? "", text: msg, role: "user") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            //清空
            newMessageText = ""
            lastMessageText = newMessageText
            withAnimation {
                scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            }
        }
    }
}


struct ChatRoomCellView: View {
    let message: Message
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        HStack {
            if message.role != ChatGPTManager.shared.gptRoleString {
                Spacer()
                VStack {
                    Text(message.text ?? "")
                        .textSelection(.enabled)
                }.padding(12)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
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
                }else if message.type == 1 {
                    //等待chatGPT回复的动画
                    ThinkingAnimationView()
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                else {
                    Text(message.text ?? "")
                        .padding(12)
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .textSelection(.enabled)
                    
                    if message.type == 2 && viewModel.messages.last?.id == message.id {
                        Button {
                            viewModel.resendMessage(sesstionId: message.sesstionId)
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

struct ChatRoomCellTextView: View {
    let textModel: MessageTextModel
    var body: some View {
        if textModel.type == .text {
            HStack {
                Text(textModel.text)
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
        }else {
            VStack {
                HStack {
                    Text(textModel.headText)
                        .foregroundColor(.white)
                        .frame(height: 20)
                        .padding(.leading, 10)
                        .textSelection(.enabled)
                    Spacer()
                    Button(action: {
                        NSPasteboard.general.prepareForNewContents()
                        NSPasteboard.general.setString(textModel.text, forType: .string)
                    }) {
                        Text("Copy")
                        Image(systemName: "doc.on.doc.fill")
                    }
                }.background(Color.white.opacity(0.4))
                    .padding(0)
                    .padding(.leading, 0)
                    
                HStack {
                    Text(textModel.text)
                        .font(.custom("SF Mono Bold", size: 14.0))
                        .kerning(0.5)
                        .lineSpacing(0.2)
                        .foregroundColor(NSColor(r: 0, g: 195, b: 135).toColor())
                        .padding(.top, 0)
                        .padding(.leading, 10)
                        .padding(.bottom, 15)
                        .textSelection(.enabled)
                    Spacer()
                }
                
                
            }.padding(.leading, 0)
                .padding(.top, 0)
                .background(Color.black.opacity(0.7))
            .cornerRadius(5)
            .frame(minWidth: 20)
        }
    }
}
