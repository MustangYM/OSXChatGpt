//
//  AIPromptInputView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/28.
//

import SwiftUI

struct AIPromptInputView: View {
    @StateObject var viewModel = AIPromptViewMdoel(isSession: true)
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var prompt: String = ""
    @State private var author: String = ""
    @State private var isToggleOn: Bool = true
    @Environment(\.colorScheme) private var colorScheme
    func cancelAction() {
        self.isPresented = false
    }
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Text("自定义提示")
                    .font(.title3)
                    .foregroundColor((colorScheme == .dark) ? .white.opacity(0.9) :.black.opacity(0.9))
                Spacer()
            }.frame(height: 40)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background((colorScheme == .dark) ? .gray.opacity(0.1) : .white)
            
            VStack {
                HStack {
                    Text("标题")
                        .font(.title3)
                        .padding(.top, 5)
                        .padding(.leading, 20)
                        .padding(.bottom, 0)
                        .frame(height: 18)
                    Text("*必填")
                        .font(Font.system(size: 11))
                        .padding(.top, 5)
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(height: 18)
                    Spacer()
                }
                HStack {
                    TextField("", text: $title)
                        .accentColor(nil)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(Font.system(size: 14))
                        .padding(10)
                        .background((colorScheme == .dark) ? .gray.opacity(0.1) :.white.opacity(0.9))
                        .cornerRadius(8)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }.padding(.leading, 20)
                    .padding(.trailing, 20)
                
                HStack {
                    Text("修饰语")
                        .font(.title3)
                        .padding(.top, 5)
                        .padding(.leading, 20)
                        .padding(.bottom, 0)
                        .frame(height: 18)
                    Text("*必填")
                        .font(Font.system(size: 11))
                        .padding(.top, 5)
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(height: 18)
                    Spacer()
                }.padding(.top, 5)
                
                HStack {
                    TextEditor(text: $prompt)
                        .font(Font.system(size: 13))
                        .padding(8)
                        .background((colorScheme == .dark) ? .gray.opacity(0.1) :.white.opacity(0.9))
                        .cornerRadius(8)
                        .frame(height: 90)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }.padding(.leading, 20)
                    .padding(.trailing, 20)
                
                HStack {
                    Text("作者")
                        .font(.title3)
                        .padding(.top, 5)
                        .padding(.leading, 20)
                        .padding(.bottom, 0)
                        .frame(height: 18)
                    Text("(选填)")
                        .font(Font.system(size: 11))
                        .padding(.top, 5)
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(height: 18)
                    Text("后台审核通过后可分享给其他人")
                        .font(Font.system(size: 10))
                        .padding(.top, 5)
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(height: 18)
                    Spacer()
                }.padding(.top, 5)
                HStack {
                    TextField("", text: $author)
                        .accentColor(nil)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(Font.system(size: 14))
                        .padding(10)
                        .background((colorScheme == .dark) ? .gray.opacity(0.1) :.white.opacity(0.9))
                        .cornerRadius(8)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }.padding(.leading, 20)
                    .padding(.trailing, 20)
                
            }
            Spacer()
            
            VStack {
                HStack {
                    Toggle("是否上传至云端", isOn: $isToggleOn)
                                    .padding()
                                    .foregroundColor(.gray)
                                    .font(Font.system(size: 13))
                    
                    Spacer()
                    Button {
                        self.isPresented = false
                    } label: {
                        Text("取消")
                    }
                    
                    Button {
                        viewModel.addPrompt(title: title, content: prompt, author: author, isToggleOn: isToggleOn)
                        self.isPresented = false
                        
                    } label: {
                        Text("确定")
                        
                    }
                    .padding(.trailing, 20)
                }
                
            }.frame(height: 44)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background((colorScheme == .dark) ? .gray.opacity(0.1) : .white)
            
            

        }.frame(width: 500, height: 380)
            .background(.gray.opacity(0.3))
        
    }
}

//struct AIPromptInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        AIPromptInputView()
//    }
//}
