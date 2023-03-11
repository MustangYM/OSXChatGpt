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
    @EnvironmentObject var viewModel: ViewModel
    @State private var searchText = ""
    @State var showNewConversationSheet = false
    
    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
                NavigationLink(destination: ChatView(conversation: conversation).environmentObject(viewModel)) {
                    ChatRowContentView(chat: conversation).environmentObject(viewModel)
                }
                    .cornerRadius(5)
            }
            .toolbar {
                let aa = viewModel.addNewConversation()
                NavigationLink(destination: ChatView(conversation: aa)) {
                    Button(action: {
                        viewModel.conversations.insert(aa, at: 0)
                        showNewConversationSheet = true
                    }) {
                        Label("New Conversation", systemImage: "plus")
                    }
                }
            }
            Text("请选择一个会话")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.navigationTitle(viewModel.currentConversation?.remark ?? "New Chat")
    }
}

/// 左边会话列表
struct ChatRowContentView: View {
    @ObservedObject var chat: Conversation
    var body: some View {
        ChatRowContentNSView(chat: chat)
            .frame(minHeight: 50, idealHeight: 50, maxHeight: 50)
    }
}

/// 左边会话列表
struct ChatRowView: View {
    @ObservedObject var chat: Conversation
    var body: some View {
        HStack {
            Image("openAI_icon")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.leading, 5)
            VStack(alignment: .leading) {
                Text(chat.remark ?? chat.lastMessage?.text ?? "New Chat")
                    .font(.headline)
                    
            }.padding(.trailing, 5)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.trailing, 5)
    }
}
struct ChatRowContentNSView: NSViewRepresentable {
    @EnvironmentObject var viewModel: ViewModel
    @ObservedObject var chat: Conversation
    @State private var showMenu = false
    @State private var editNote: String = ""
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update view properties and state here.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSMenuDelegate {
        var parent: ChatRowContentNSView
        
        init(_ parent: ChatRowContentNSView) {
            self.parent = parent
            super.init()
        }
        
        @objc func handleRightClick(_ sender: NSClickGestureRecognizer) {
            if sender.state == .ended {
                print("双击鼠标")
                
                let menu = NSMenu(title: "123")
                menu.delegate = self
                let editMenuItem = NSMenuItem(title: "编辑备注", action: #selector(edit), keyEquivalent: "")
                let deleteMenuItem = NSMenuItem(title: "删除会话", action: #selector(delete), keyEquivalent: "")
                editMenuItem.target = self
                deleteMenuItem.target = self
                menu.addItem(editMenuItem)
                menu.addItem(deleteMenuItem)
                menu.popUp(positioning: nil, at: sender.location(in: sender.view!), in: sender.view!)
                parent.showMenu = true
            }
        }
        func menuDidClose(_ menu: NSMenu) {
//            print("menu menuDidClose!")
        }
        
        @MainActor @objc func edit() {
            parent.editNote = parent.chat.remark ?? ""
            let alert = NSAlert()
            alert.messageText = "修改会话备注"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            inputTextField.stringValue = parent.editNote
            alert.accessoryView = inputTextField
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                parent.chat.remark = inputTextField.stringValue
                parent.viewModel.updateConversation(sesstionId: parent.chat.sesstionId, remark: parent.chat.remark)
            }
        }
        
        @MainActor @objc func delete() {
            parent.viewModel.deleteConversation(parent.chat)
        }

    }
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 3
        let swiftUIView = ChatRowView(chat: chat)
            .frame(width: 300, height: 40)
        let hostingView = NSHostingView(rootView: swiftUIView)
        view.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        let gestureRecognizer = NSClickGestureRecognizer(target: context.coordinator,
                                                          action: #selector(Coordinator.handleRightClick(_:)))
        gestureRecognizer.buttonMask = 0x2 // 双击事件
        view.addGestureRecognizer(gestureRecognizer)
        return view
    }

}
struct ChatMessageView: View {
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
    var conversation: Conversation
    var isNewConversation: Bool = false
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
                                ChatMessageView(message: message)
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
        viewModel.addNewMessage(sesstionId: conversation.sesstionId, text: replaceStr, role: "user") {
            scrollView?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
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

