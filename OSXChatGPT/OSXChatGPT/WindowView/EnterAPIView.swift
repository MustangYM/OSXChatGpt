//
//  EnterAPIView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI

struct EnterAPIView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var apiKey: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Your OpenAI API Key:")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Text("You need a working OpenAI Api Key in order to use OSXChatGPT")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
            
            Button(action: {
                if let url = URL(string: "https://platform.openai.com/account/api-keys") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text("->Get your API key from Open AI dashboard")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
            }
            .buttonStyle(BorderlessButtonStyle())//删除背景色
            
            TextField("Enter your API key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 400, height: 50)
            
            HStack(spacing: 50, content: {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                }
                .frame(width: 100, height: 40) // 设置按钮大小
                .background(Color.gray)
                .cornerRadius(10)
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    // TODO: save the API key
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                }
                .frame(width: 100, height: 40) // 设置按钮大小
                .background(Color.blue)
                .cornerRadius(10)
                .buttonStyle(BorderlessButtonStyle())
            })
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 0)
            
            Text("The app will connect to OpenAI API server to check if your API Key is working properly.")
                .font(.footnote)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 500, height: 300)
    }
}

struct EnterAPIView_Previews: PreviewProvider {
    static var previews: some View {
        EnterAPIView()
    }
}
