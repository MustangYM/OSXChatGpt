//
//  UserInitializeView.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//
import Colorful
import SwiftUI

struct UserInitializeView: View {
    @State var openArgumentSeet: Bool = false
    @State var showGoogleSetting: Bool = false
    @State var apiKey: String = ChatGPTManager.shared.getMaskApiKey()
    static let appVersion: String =
        Bundle
            .main
            .infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "unknown"
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image("App_Icon")
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.top, 40)

                HStack(spacing: 0) {
                    Text("OSXChatGPT")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.clear)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.pink, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(Text("OSXChatGPT")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        )
                }
                .padding(.bottom, 20)
                VStack(alignment: .leading, spacing: 10){
                    HStack {
                        Text(Localization.fasterResponse.localized)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text(Localization.PromptLibrary.localized)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text(Localization.NoLoginRequired.localized)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text(Localization.NoMonthlyFee.localized)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                
                //**BorderlessButtonStyle() -> PlainButtonStyle(), 前者导致侧边栏无法展开
                VStack (spacing: 10, content: {
                    Button(action: {
                        if let url = URL(string: "https://github.com/MustangYM/OSXChatGpt") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 0, content:{
                            Image("github-fill 1")
                            Text(Localization.BetterApplication.localized)
                                .foregroundColor(.blue)
                                .frame(maxWidth: 300, alignment: .leading)
                                .padding(.horizontal, 5)
                        }).padding(.leading, 60)
                    }.buttonStyle(PlainButtonStyle())//删除背景色
                })
                HStack {
                    // 添加API密钥按钮
                    Button(action: {
                        openArgumentSeet.toggle()
                    }) {
                        HStack(spacing: 8) {
                            if apiKey.count > 0 {
                                Image(systemName: "person.fill.checkmark")
                                Text(Localization.UpdateAPIKey.localized)
                            } else {
                                Image(systemName: "key.radiowaves.forward.fill")
                                Text(Localization.EnterAPIKey.localized)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(apiKey.count > 0 ? Color.green : Color.red)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle()) // 隐藏按钮的默认样式
                    
                    
                    Button(action: {
                        showGoogleSetting.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Text("谷歌搜索配置")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.leading, 16)
                    }
                    .buttonStyle(PlainButtonStyle()) // 隐藏按钮的默认样式
                }
                
                if apiKey.count > 0 {
                    Text(apiKey)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                
                
                
                Spacer()
            }
            .sheet(isPresented: $openArgumentSeet) {
                EnterAPIView(apiKey: $apiKey)
            }
            .sheet(isPresented: $showGoogleSetting) {
                GoogleSearchSettingView()
            }
            VStack {
                Spacer()
                Text("Beta v\(UserInitializeView.appVersion)")
                    .font(.system(size: 12, weight: .light, design: .rounded))
                    .opacity(0.5)
                Spacer().frame(height: 30)
            }
        }
//        .padding(.bottom,150)
       
    }
}

extension Color {
    static func gradient(
        _ gradient: Gradient,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> LinearGradient {
        LinearGradient(
            gradient: gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

struct UserInitializeView_Previews: PreviewProvider {
    static var previews: some View {
        UserInitializeView()
    }
}
