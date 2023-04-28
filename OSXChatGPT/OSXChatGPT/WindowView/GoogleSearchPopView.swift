//
//  GoogleSearchConfigView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/26.
//

import SwiftUI

struct GoogleSearchPopView: View {
    @Binding var showSearchView: Bool
    @State private var progress: Float = 0.5
    @EnvironmentObject var viewModel: ViewModel
    @State private var isOn = false
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Toggle("谷歌搜索", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 0)
            Divider()
            if isOn {
                GoogleSearchCountSliderView()
                Divider()
                Button {
                    withAnimation {
                        showSearchView.toggle()
                        viewModel.currentConversation = nil
                        viewModel.showUserInitialize = true
                    }
                } label: {
                    HStack {
                        Text("谷歌APIKey")
                        Text("未配置")
                    }
                }.buttonStyle(PlainButtonStyle())
                    .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                Divider()
                Button {
                    withAnimation {
                        showSearchView.toggle()
                        viewModel.currentConversation = nil
                        viewModel.showUserInitialize = true
                    }
                } label: {
                    HStack {
                        Text("搜索引擎ID")
                        Text("未配置")
                    }
                }.buttonStyle(PlainButtonStyle())
                    .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
            }else {
                Text("1、搜索需要配置APIKey与搜索引擎ID")
                    .lineLimit(3)
                    .padding(EdgeInsets(top: 15, leading: 16, bottom: 5, trailing: 16))
                Text("2、搜索结果超出最大令牌后会自动截取")
                    .lineLimit(3)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 15, trailing: 16))
            }
            Spacer()
            
        }
        .frame(width: 160, height: 200)
    }
}


struct GoogleSearchCountSliderView: View {
    @State private var progress: Float = 3
    @State private var change: String = "3"
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack {
            HStack {
                Text("获取搜索结果数")
                Text(change)
                    .frame(width: 10)
            }.padding(0)
//                .background(.orange)
            Slider(value: $progress, in: 1...10, step: 1) {
//                Text(change)
            }
            .frame(height: 10)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 0)
            .padding(.bottom, 0)
//            .background(.green)
//            Slider(value: $progress) {
//                Text(change)
//            }
//            Slider(value: $progress) {
//
//            } minimumValueLabel: {
//                Text("0.0")
//            } maximumValueLabel: {
//                Text("2.0")
//            }.padding(.horizontal)
//                .frame(width: 160)
//                .background(.orange)
            
        }
        .padding(.top, 0)
        .padding(.bottom, 0)
        .onChange(of: progress) { newValue in
            let formattedValue = String(format: "%.0f", newValue)
            change = formattedValue
            
        }
        .onAppear {
//            if let gpt = viewModel.currentConversation?.chatGPT {
//                progress = Float(gpt.temperature / 2)
//                let formattedValue = String(format: "%.1f", progress * 2)
//                change = formattedValue
//            }
        }
        .onDisappear {
//            viewModel.currentConversation?.chatGPT?.temperature = Double(progress * 2)
//            viewModel.updateConversation(sesstion: viewModel.currentConversation)
//            temperature = change
        }
    }
}


