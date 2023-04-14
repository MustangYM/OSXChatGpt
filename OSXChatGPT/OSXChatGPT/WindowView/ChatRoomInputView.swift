//
//  ChatRoomInputView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/25.
//

import SwiftUI

struct ChatRoomInputView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var newMessageText = ""
    @State private var lastMessageText = ""
    @Binding var inputViewHeight: CGFloat
    var body: some View {
        GeometryReader { geometry in
            if #available(macOS 13.0, *) {
                TextEditor(text: $newMessageText)
                    .font(.title3)
                    .lineSpacing(2)
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
                    .lineSpacing(2)
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
        .padding(0)
        .frame(height: inputViewHeight)
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
                    sendMessage(scrollView: nil, text: lastMessageText)
                }
            }
        }
        lastMessageText = newMessageText
    }
    
    private func sendMessage(scrollView: ScrollViewProxy?, text: String) {
        guard !text.isEmpty else { return }
        let msg = String(text)
        let replaceStr = msg.replacingOccurrences(of: " ", with: "")
        if replaceStr.count == 0 {
            cleanText()
            return
        }else if replaceStr.contains("\n") {
            let repl = replaceStr.replacingOccurrences(of: "\n", with: "")
            if repl.count == 0 {
                cleanText()
                return
            }
        }
        viewModel.addNewMessage(sesstionId: viewModel.currentConversation?.sesstionId ?? "", text: msg, role: "user", prompt: viewModel.currentConversation?.prompt?.prompt) {
            
        }
        //清空
        cleanText()
    }
    
    private func cleanText() {
        newMessageText = ""
        lastMessageText = ""
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
    
}

//struct ChatRoomInputView_Previews: PreviewProvider {
//    @State private var inputViewSize = CGSize(width: 200, height: 200)
//    static var previews: some View {
//        ChatRoomInputView(size: $inputViewSize)
//    }
//}
