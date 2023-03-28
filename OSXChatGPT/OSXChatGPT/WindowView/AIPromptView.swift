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
struct ListItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var isSelected: Bool = false
    var title: String = "11"
    var content: String = "444"
}
struct AIPromptPopView: View {
    @Binding var showInputView: Bool
    @Binding var showPopover: Bool
    @State private var isPresented = false
    @State var selectedItem :ListItem?
    let items: [ListItem] = [ListItem(name: "123", isSelected: false),
                            ListItem(name: "345", isSelected: false),
                            ListItem(name: "567", isSelected: true)]
    var body: some View {
        ZStack {
//            Spacer()
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
        List(items) { item in
            AIPromptPopCellView(
                item: item,
                isSelected: self.selectedItem == item
            ) {
                self.selectedItem = item
            }
        }.frame(width: 560, height: 380)
    }
}

struct AIPromptPopCellView: View {
    let item: ListItem
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }.padding(.leading, 2)
                
                Spacer()
            }
            .frame(height: 60)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                AIPromptViewMdoel.randomColor()
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
