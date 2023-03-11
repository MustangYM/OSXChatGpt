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
    @State private var searchText = ""
    @State private var shouldNavigate = false
    
    var body: some View {
        ZStack {
            ColorfulView(colors: [.accentColor], colorCount: 4)
                .ignoresSafeArea()
            VStack {
                HStack {
                    SearchBar(text: $searchText)
                        .frame(minWidth: 100, idealWidth: 200, maxWidth: 200, minHeight: 40, idealHeight: 40, maxHeight: 40)
                        .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 0))
                    NavigationLink(destination: ChatRoomView(sesstionId: viewModel.createSesstionId()).environmentObject(viewModel), isActive: $shouldNavigate) {
                        Button {
                            self.shouldNavigate = true
                        } label: {
                            Text("New")
                                .padding(5)
                            Spacer()
                        }.background(Color.clear)


                    }.frame(minWidth: 30, idealWidth: 30, maxWidth: 30, minHeight: 30, idealHeight: 30, maxHeight: 30)
                        .padding(.init(top: 10, leading: 0, bottom: 0, trailing: 10))
                    
                }.frame(minHeight: 40, idealHeight: 40, maxHeight: 50)
                Divider()
                List(viewModel.conversations.filter({ searchText.isEmpty ? true : $0.sesstionId.localizedCaseInsensitiveContains(searchText) })) { chat in
                    NavigationLink(destination: ChatRoomView(sesstionId: chat.sesstionId).environmentObject(viewModel)) {
                        ChatRowContent(chat: chat)
                    }
                }
                .listStyle(SidebarListStyle())
                .padding(.top, 1)
                
                Spacer()
            }
            .frame(minWidth: 250, idealWidth: 300, maxWidth: 300)
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

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
    }
}