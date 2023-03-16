//
//  SessionsView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI
import Colorful

struct SessionsView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            ColorfulView(colors: [.accentColor], colorCount: 4)
                .ignoresSafeArea()
            VStack {
                HStack(spacing: 10, content: {
                    NavigationLink(destination: ChatRoomView(conversation: viewModel.currentConversation).environmentObject(viewModel), isActive: $viewModel.createNewChat) {
                    }.buttonStyle(BorderlessButtonStyle())
                    Spacer()
                    Button(action: {
                        // 点击 New Chat 按钮的操作
                        viewModel.currentConversation = viewModel.addNewConversation()
                        viewModel.createNewChat = true
                    }) {
                        HStack(spacing: 0) {
                            Text("     ")
                            Image(systemName: "plus.message.fill")
                            Text("New Chat        ")
                        }
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,0)
                    NavigationLink(destination: UserInitializeView().environmentObject(viewModel), isActive: $viewModel.showUserInitialize) {
                        Button(action: {
                            // 点击右边按钮的操作
                            viewModel.currentConversation = nil;//先取消会话
                            viewModel.showUserInitialize = true//再显示设置
                            KeyboardMonitor.shared.stopKeyMonitor()
                            KeyboardMonitor.shared.stopMonitorPasteboard()
                        }) {
                            Image(systemName: "gear")
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .cornerRadius(5)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 30)
                    }.buttonStyle(BorderlessButtonStyle())
                    
                })
                .frame(height: 20)
                .sheet(isPresented: $viewModel.showEditRemark) {
                    EidtSessionRemarkView(remark: viewModel.editConversation?.remark ?? "").environmentObject(viewModel)
                }
                .onAppear  {
                    viewModel.showUserInitialize = true
                }
                Spacer()
                    .frame(height: 20)
                List {
                    ForEach(viewModel.conversations, id: \.self) { conversation in
                        NavigationLink(destination: ChatRoomView(conversation: conversation).environmentObject(viewModel), tag: conversation, selection: $viewModel.currentConversation) {
                            ChatRowContentView(chat: conversation).environmentObject(viewModel)
                            
                        }
                        .cornerRadius(5)
                    }
                }

            }
            .leftSessionContentSize()
            
        }
    }
}


/// 左边会话列表
struct ChatRowContentView: View {
    @ObservedObject var chat: Conversation
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        ChatRowContentNSView(chat: chat).environmentObject(viewModel)
            .frame(minHeight: 50, idealHeight: 50, maxHeight: 50)
    }
}

/// 左边会话列表
struct ChatRowView: View {
    @ObservedObject var chat: Conversation
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            Image("openAI_icon")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.leading, 5)
            VStack(alignment: .leading) {
                Text(chat.remark ?? chat.lastMessage?.text ?? "New Chat")
                    .font(.headline)
                Spacer()
                if chat.updateData != nil {
                    let dateTime = dateFormatter(chat.updateData!)
                    Text(dateTime)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    
            }.padding(.trailing, 5)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.trailing, 5)
    }
    
    private func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
         formatter.dateFormat = "yyyy/MM/dd"
         
         let calendar = Calendar.current
         if calendar.isDateInToday(date) {
             formatter.dateFormat = "HH:mm"
         }
    
         return formatter.string(from: date)
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
                print("右键鼠标")
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
            parent.viewModel.editConversation = parent.chat
            parent.viewModel.showEditRemark = true
        }
        
        @MainActor @objc func delete() {
            parent.viewModel.deleteConversation(parent.chat)
            if parent.viewModel.conversations.count == 0 {
                //已经没有会话了，显示其他
                parent.viewModel.showUserInitialize = true
            }else if parent.viewModel.currentConversation == nil {
                parent.viewModel.showUserInitialize = true
            }
        }

    }
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 3
        let swiftUIView = ChatRowView(chat: chat).environmentObject(viewModel)
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

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
    }
}
