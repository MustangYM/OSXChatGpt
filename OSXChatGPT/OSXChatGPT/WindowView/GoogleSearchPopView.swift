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
    @Binding var showSearchSettingView : Bool
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
                GoogleSearchTimeSliderView()
            }else {
                HStack {
                    Text("谷歌APIKey")
                    Button {
                        withAnimation {
                            showSearchView.toggle()
                            showSearchSettingView = true
                        }
                    } label: {
                        HStack {
                            if ChatGPTManager.shared.getGoogleSearchMaskApiKey().isEmpty {
                                Text("[未配置]")
                                    .foregroundColor(.red)
                            }else {
                                Text("[更新key]").foregroundColor(.green)
                            }
                            
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
                .frame(height: 45)
                Divider()
                HStack {
                    Text("搜索引擎ID")
                    Button {
                        withAnimation {
                            showSearchView.toggle()
                            showSearchSettingView = true
                        }
                    } label: {
                        HStack {
                            if ChatGPTManager.shared.getGoogleSearchEngineMaskApiKey().isEmpty {
                                Text("[未配置]")
                                    .foregroundColor(.red)
                            }else {
                                Text("[更新ID]")
                                    .foregroundColor(.green)
                            }
                            
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
                .frame(height: 45)
            }
            Spacer()
            
        }
        .frame(width: 160, height: 200)
        .onChange(of: isOn) { newValue in
            var search = viewModel.currentConversation?.search
            if search == nil {
                search = viewModel.cerateDefaultSearch()
            }
            search?.open = newValue
            viewModel.currentConversation?.search = search
            viewModel.updateConversation(sesstionId: viewModel.currentConversation!.sesstionId, search: search)
        }
        .onAppear {
            if let search = viewModel.currentConversation?.search, search.open {
                self.isOn = true
            }else {
                self.isOn = false
            }
        }
    }
}

struct GoogleSearchTimeSliderView: View {
    @State private var progress: Float = 0
    @State private var change: String = "无限"
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack {
            HStack {
                Text("时间筛选")
                    .padding(0)
                Text("(\(change))")
                    .padding(0)
                    .frame(width: 40)
            }.padding(0)
            Slider(value: $progress, in: 1...5, step: 1) {

            }
            .frame(height: 10)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 0)
            .padding(.bottom, 0)
            
        }
        .frame(height: 45)
        .onChange(of: progress) { newValue in
            let formattedValue = String(format: "%.0f", newValue)
            change = formattedValue
            if newValue == 2 {
                change = "1周"
            }else if newValue == 3 {
                change = "1月"
            }else if newValue == 4 {
                change = "6月"
            }else if newValue == 5 {
                change = "1年"
            }else {
                change = "无限"
            }
            
        }
        .onAppear {
            if let search = viewModel.currentConversation?.search {
                progress = Float(search.dateType.rawValue)
            }
        }
        .onDisappear {
            let search = viewModel.currentConversation?.search
            search?.dateType = GoogleSearchDate(rawValue: Int16(progress)) ?? .unlimited
            viewModel.currentConversation?.search = search
            viewModel.updateConversation(sesstionId: viewModel.currentConversation!.sesstionId, search: search)
        }
    }
}

struct GoogleSearchCountSliderView: View {
    @State private var progress: Float = 3
    @State private var change: String = "3"
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack {
            HStack {
                Text("搜索结果数")
                Text("(\(change))")
                    .frame(width: 26)
            }.padding(0)
            Slider(value: $progress, in: 1...10, step: 1) {
                
            }
            .frame(height: 10)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 0)
            .padding(.bottom, 0)
            
        }
        .frame(height: 45)
        .onChange(of: progress) { newValue in
            let formattedValue = String(format: "%.0f", newValue)
            change = formattedValue
            
        }
        .onAppear {
            if let search = viewModel.currentConversation?.search {
                progress = Float(search.maxSearchResult)
            }
        }
        .onDisappear {
            let search = viewModel.currentConversation?.search
            search?.maxSearchResult = Int16(progress)
            viewModel.currentConversation?.search = search
            viewModel.updateConversation(sesstionId: viewModel.currentConversation!.sesstionId, search: search)
        }
    }
}


