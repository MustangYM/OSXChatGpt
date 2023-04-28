//
//  GoogleSearchSettingView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/27.
//

import SwiftUI

struct GoogleSearchSettingView: View {
//    private lazy var googleSearchApiKey : String = {
//        let key = UserDefaults.standard.value(forKey: OSXChatGoogleSearchKEY) as? String
//        return key ?? ""
//    }()
//    private lazy var googleSearchEngineID : String = {
//        let key = UserDefaults.standard.value(forKey: OSXChatGoogleEngineKEY) as? String
//        return key ?? ""
//    }()
    @Environment(\.presentationMode) var presentationMode
    @State var p_apiKey: String = ChatGPTManager.shared.getGoogleSearchMaskApiKey()
    @State var p_engine: String = ChatGPTManager.shared.getGoogleSearchEngineMaskApiKey()
    var body: some View {
        VStack() {
            Text("谷歌搜索配置")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Text("API密钥获取流程: API和服务->新建项目->凭据->创建凭据->API密钥")
                .font(.callout)
                .padding(.top, 15)
                .padding(.bottom, 5)
            Text("引擎ID获取流程: 可编程搜索引擎->添加->概览->基本->搜索引擎ID")
                .font(.callout)
                .padding(.top, 0)
                .padding(.bottom, 10)
            HStack {
                Button(action: {
                    if let url = URL(string: "https://console.cloud.google.com/apis") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("获取谷歌Api密钥")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(BorderlessButtonStyle())//删除背景色
                
                Button(action: {
                    if let url = URL(string: "https://programmablesearchengine.google.com") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("获取谷歌搜索引擎ID")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(BorderlessButtonStyle())//删除背景色
            }
            
            
            TextField("输入你的谷歌API密钥", text: $p_apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 400, height: 30)
                .padding(.top, 6)
            
            TextField("输入你的谷歌引擎ID", text: $p_engine)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 400, height: 30)
            
            HStack(spacing: 80, content: {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("取消")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                }
                .frame(width: 100, height: 30) // 设置按钮大小
                .background(Color.gray)
                .cornerRadius(10)
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    ChatGPTManager.shared.updateGoogleSearchApiKey(apiKey: p_apiKey)
                    ChatGPTManager.shared.updateGoogleSearchEngineID(engineID: p_engine)
                    self.presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("保存")
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
            .padding(.top, 10)
            
            
            Spacer()
        }
        .frame(width: 500, height: 300)
    }
}

