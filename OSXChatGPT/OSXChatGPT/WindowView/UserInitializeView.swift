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
    
    var body: some View {
        ColorfulView(colors: [.accentColor], colorCount: 4)
            .ignoresSafeArea()
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
                Text("A Better macOS application For ChatGPT")
                    .font(.system(.body, design: .rounded))

                // 添加API密钥按钮
                Button(action: {
                    openArgumentSeet.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "key.radiowaves.forward.fill")
                        Text("Enter API Key")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // 隐藏按钮的默认样式
            }
            .sheet(isPresented: $openArgumentSeet) {
                EnterAPIView()
            }
            
        }
        .padding(.top,100)
        .padding(.bottom,300)
        .padding(.leading,200)
        .padding(.trailing,200)

        
        VStack {
            Spacer()
            Text("v1.0.0")
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
