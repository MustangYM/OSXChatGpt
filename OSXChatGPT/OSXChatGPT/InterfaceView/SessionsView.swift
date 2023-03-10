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
                    NavigationLink(destination: ChatView(sesstionId: viewModel.createSesstionId()).environmentObject(viewModel), isActive: $shouldNavigate) {
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
                    NavigationLink(destination: ChatView(sesstionId: chat.sesstionId).environmentObject(viewModel)) {
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



struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
    }
}
