//
//  ChatRoomToolBar.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/25.
//

import SwiftUI

struct ChatRoomToolBar: View {
    var body: some View {
        Spacer()
        HStack {
            BrowserView(items: ChatGPTModel.allCases, title: "模型", item: ChatGPTManager.shared.model) { model in
                ChatGPTManager.shared.model = model
            }
            .frame(width: 60)
            BrowserView(items: ChatGPTContext.allCases, title: "上下文", item: ChatGPTManager.shared.askContextCount) { model in
                ChatGPTManager.shared.askContextCount = model
            }
            .frame(width: 70)
            BrowserView(items: ChatGPTAnswerType.allCases, title: "应答", item: ChatGPTManager.shared.answerType) { model in
                ChatGPTManager.shared.answerType = model
            }
            .frame(width: 60)
            Spacer()
        }.padding(.leading, 12)
        
    }
}

protocol ToolBarMenuProtocol: Hashable {
    var value: String { get }
    
}

struct BrowserView<T: ToolBarMenuProtocol>: View {
    let items: [T]
    let title: String
    @State var item: T
    var callback: ((T) -> Void)
    
    private let checkedSymbol: String = "checkmark.square.fill"
    
    var body: some View {
        VStack() {
            MenuButton(title) {
                ForEach(items, id: \.self) { item in
                    Button {
                        self.item = item
                        callback(item)
                    } label: {
                        HStack {
                            if self.item == item {
                                Image(systemName: checkedSymbol)
                            }
                            Text("\(item.value)")
                        }
                    }
                }
            }
            .menuButtonStyle(DefaultMenuButtonStyle())
            .padding(0)
            .foregroundColor(.white)
        }
    }
}
