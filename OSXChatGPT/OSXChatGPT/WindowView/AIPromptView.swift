//
//  AIPromptView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/27.
//

import SwiftUI




struct AIPromptView: View {
    let sesstionId: String? //有则表示在会话中打开
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AIPromptPopView: View {
    @EnvironmentObject var viewModel: ViewModel
    @StateObject var data = AIPromptSessionViewMdoel()
    @Binding var showInputView: Bool
    @Binding var showPopover: Bool
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            VStack {
                            Spacer()
                Text("选择提示")
                    .font(.title3)
                    .foregroundColor(.black.opacity(0.9))
                            Spacer()
                
            }
            HStack {
                Spacer()
                Button {
                    self.showPopover = false
                    self.showInputView = true
                } label: {
                    Text("自定义")
                }
                .padding(10)
            }
        }
        List(data.allPrompts) { item in
            AIPromptPopCellView(item: item, isSelected: data.selectedItem == item) {
                data.selectedItem = item
            }.contextMenu {
                Button(action: {
                    data.deletePrompt(prompt: item)
                }) {
                    Text("删除")
                }
            }
        }.frame(width: 560, height: 380)
            .onAppear {
                if let conversation = viewModel.currentConversation {
                    data.fetchAllPrompts(session: conversation)
                }
            }
            .onDisappear {
                viewModel.updateConversation(sesstionId: viewModel.currentConversation!.sesstionId, prompt: data.selectedItem!)
            }
    }
}

struct AIPromptPopCellView: View {
    let item: Prompt
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            HStack {
                if self.isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .padding(5)
                        
                } else {
                    Circle()
                        .stroke(Color.blue, lineWidth: 1)
                        .frame(width: 20, height: 20)
                        .padding(5)
                }
                if item.type == 1 {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("【默认无修饰语】")
                                .font(Font.system(size: 15))
                                .foregroundColor(.white)
                                .padding(.trailing, 6)
                                .padding(.bottom, 6)
                            Text("当前选中的修饰语")
                                .font(Font.system(size: 14))
                                .foregroundColor(.white)
                                .padding(.bottom, 6)
                        }
                        Text("每个会话只能选择一个修饰语, 也可以自定义添加修饰语")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(1))
                    }.padding(.leading, 2)
                }else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title ?? "")
                            .font(.headline)
                            .foregroundColor(.white)
                            .foregroundColor(.primary)
                            .padding(.bottom, 6)
                        Text(item.prompt ?? "")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(1))
                    }.padding(.leading, 2)
                }
                
                Spacer()
            }
            .frame(height: 60)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                item.color
            )
            .cornerRadius(6)
            .onTapGesture {
                self.action()
            }
        }
}

struct AIPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AIPromptView(sesstionId: nil)
    }
}
