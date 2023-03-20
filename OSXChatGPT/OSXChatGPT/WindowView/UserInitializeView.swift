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

                VStack(alignment: .leading, spacing: 10){
                    HStack {
                        Text("✅ Faster response      ✅ Local Chat History")
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text("✅ Prompt Library        ✅ Run locally on desktop")
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text("✅ No login required    ✅ Use your own API key")
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    HStack {
                        Text("✅ No monthly fee        and more soon...")
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
                            Text("A Better macOS application for ChatGPT")
                                .foregroundColor(.blue)
                                .frame(maxWidth: 250, alignment: .leading)
                                .padding(.horizontal, 5)
                        })
                    }.buttonStyle(PlainButtonStyle())//删除背景色

                    Button(action: {
                        if let url = URL(string: "https://www.yemays.com/") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 0, content:{
                            Image(systemName: "play.tv.fill")
                            Text("湖畔机械厂电影院")
                                .foregroundColor(.blue)
                                .frame(maxWidth: 250, alignment: .leading)
                                .padding(.horizontal, 5)
                        })
                    }.buttonStyle(PlainButtonStyle())//删除背景色

                    Button(action: {
                        if let url = URL(string: "https://5imac.net/") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 0, content:{
                            Image(systemName: "desktopcomputer.and.arrow.down")
                            Text("湖畔机械厂员工搬运Mac软件资源网")
                                .foregroundColor(.blue)
                                .frame(maxWidth: 250, alignment: .leading)
                                .padding(.horizontal, 5)
                        })
                    }.buttonStyle(PlainButtonStyle())//删除背景色
                })
                
                // 添加API密钥按钮
                Button(action: {
                    openArgumentSeet.toggle()
                }) {
                    HStack(spacing: 8) {
                        if apiKey.count > 0 {
                            Image(systemName: "person.fill.checkmark")
                            Text("Update API Key")
                        } else {
                            Image(systemName: "key.radiowaves.forward.fill")
                            Text("Enter API Key")
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(apiKey.count > 0 ? Color.green : Color.red)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // 隐藏按钮的默认样式
                
                if apiKey.count > 0 {
                    Text(apiKey)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .sheet(isPresented: $openArgumentSeet) {
                EnterAPIView(apiKey: $apiKey)
            }
            
        }
        .padding(.bottom,150)
        VStack {
            Spacer()
            Text("Beta v\(UserInitializeView.appVersion)")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .opacity(0.5)
            Spacer().frame(height: 30)
        }
       
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
