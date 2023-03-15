//
//  EidtSessionRemarkView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/15.
//

import SwiftUI

struct EidtSessionRemarkView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var remark: String
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Conversation Remark:")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            TextField("Enter remark", text: $remark)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, height: 50)
            
            HStack(spacing: 20, content: {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                }
                .frame(width: 100, height: 30) // 设置按钮大小
                .background(Color.gray)
                .cornerRadius(10)
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    viewModel.updateConversation(sesstionId: viewModel.editConversation?.sesstionId ?? "", remark: remark)
                    viewModel.editConversation = nil
                    self.presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                }
                .frame(width: 100, height: 30) // 设置按钮大小
                .background(Color.blue)
                .cornerRadius(10)
                .buttonStyle(BorderlessButtonStyle())
            })
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 0)
        }
        .frame(width: 300, height: 200)
    }
}

struct EidtSessionRemarkView_Previews: PreviewProvider {
    static var previews: some View {
        EidtSessionRemarkView(remark: "")
    }
}
