//
//  ChatRoomToolBar.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/25.
//

import SwiftUI

struct ChatRoomToolBar: View {
    @State private var showPopover = false
    @State private var showInputView = false
    @State private var showDragView = false
    @State private var showSearchView = false
    @State private var showSearchSettingView = false
    @State private var showExporting = false
    @State private var temperature: String = ""
    @State private var model: String = ""
    @State private var context: String = ""
    @State private var isOn: Bool = false
    @State var showPluginView: Bool = false //显示插件
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isAnswerTypeTrue = ChatGPTManager.shared.answerType.valueBool
    var body: some View {
        HStack {
            MenuButton(Localization.ParameterAdjustment.localized) {
                Button(Localization.TemperatureT(temperature).localized) {
                    showDragView.toggle()
                }
                .padding(.leading, 0)
                
                BrowserView(items: ChatGPTModel.allCases, title: Localization.ModelT(model).localized, item: viewModel.currentConversation?.chatGPT?.modelType ?? .gpt35turbo) { model in
                    viewModel.currentConversation?.chatGPT?.modelType = model
                    viewModel.updateConversation(sesstion: viewModel.currentConversation)
                    self.model = model.value
                }
                .padding(.leading, 0)
                .frame(width: 100)
                
                BrowserView(items: ChatGPTContext.allCases, title: Localization.ContextT(context).localized, item: viewModel.currentConversation?.chatGPT?.context ?? .context3) { model in
                    viewModel.currentConversation?.chatGPT?.context = model
                    viewModel.updateConversation(sesstion: viewModel.currentConversation)
                    context = model.value
                }
                .padding(.leading, 0)
                .frame(width: 70)
                
            }
            .padding(.leading, 0)
            .frame(width: (Locale.current.languageCode == "zh") ? 85 : 95)
            .popover(isPresented: $showDragView, arrowEdge: .top) {
                TemperatureSliderView(temperature: $temperature).environmentObject(viewModel)
            }
            
            BrowserView(items: ChatGPTAnswerType.allCases, title: Localization.Answer.localized, item: ChatGPTManager.shared.answerType) { model in
                ChatGPTManager.shared.answerType = model
            }
            .frame(width: (Locale.current.languageCode == "zh") ? 60 : 77)
            
            BrowserView1(items: MessageExportType.allCases, title: Localization.ExportRecord.localized, item: MessageExportType.none) { model in
                viewModel.exportDataType = model
                self.showExporting.toggle()
            }
            .frame(width: (Locale.current.languageCode == "zh") ? 85 : 73)
            .sheet(isPresented: $showExporting, content: {
                ExportView(type: viewModel.exportDataType, messages: ExportMessageViewModel.createDatas(viewModel.messages))
            })
            
            Button(Localization.Prompts.localized) {
                showPopover.toggle()
            }
            .popover(isPresented: $showPopover) {
                AIPromptPopView(showInputView: $showInputView, showPopover: $showPopover).environmentObject(viewModel)
            }

            
            Button(Localization.ClearMessage.localized) {
                viewModel.messages.removeAll()
                viewModel.deleteAllMessage(sesstionId: viewModel.currentConversation?.sesstionId ?? "")
                viewModel.updateConversation(sesstionId: viewModel.currentConversation?.sesstionId ?? "", message: nil)
            }
            
//            Button {
//                showSearchView.toggle()
//            } label: {
//                Text("谷歌搜索")
//            }
//            .popover(isPresented: $showSearchSettingView) {
//                GoogleSearchSettingView().environmentObject(viewModel)
//            }
//            .popover(isPresented: $showSearchView) {
//                GoogleSearchPopView(showSearchView: $showSearchView, showSearchSettingView: $showSearchSettingView).environmentObject(viewModel)
//            }
            PluginToolView(showPluginView: $showPluginView, isDisabledPlugin: $viewModel.isDisabledPlugin)
                .sheet(isPresented: $showPluginView, content: {
                    PluginPopView(plugins: PluginViewModel.fetchAllInstallPlugins(viewModel.currentConversation?.plugin?.array as? [PluginAPIInstall] ?? [])).environmentObject(viewModel)
                })
            
            
            
            
            Spacer()
            if viewModel.showStopAnswerBtn {
                Button(Localization.StopAnswer.localized) {
                    viewModel.cancel()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        viewModel.showStopAnswerBtn = false
                    }
                }.padding(.trailing, 15)
            }
            
            
            
            
            
        }
        .padding(.leading, 12)
        .background(Color.clear)
        
        
        .onAppear {
            let formattedValue = viewModel.currentConversation?.chatGPT?.temperatureValue ?? Localization.Empty.localized
            self.temperature = formattedValue
            
            self.model = viewModel.currentConversation?.chatGPT?.modelType.value ?? Localization.Empty.localized
            self.context = viewModel.currentConversation?.chatGPT?.context.value ?? Localization.Empty.localized
        }
        
    }
}

protocol ToolBarMenuProtocol: Hashable {
    var value: String { get }
    
}

struct BrowserView<T: ToolBarMenuProtocol>: View {
    let items: [T]
    let title: String
    @State var item: T
    var callback: ((T) -> Void)
    
    private let checkedSymbol: String = "checkmark.square.fill"
    
    var body: some View {
        VStack() {
            MenuButton(title) {
                ForEach(items, id: \.self) { item in
                    Button {
                        self.item = item
                        callback(item)
                    } label: {
                        HStack {
                            if self.item == item {
                                Image(systemName: checkedSymbol)
                            }
                            Text("\(item.value)")
                        }
                    }
                }
            }
            .menuButtonStyle(DefaultMenuButtonStyle())
            .padding(0)
            .foregroundColor(.white)
        }
    }
}

struct BrowserView1<T: ToolBarMenuProtocol>: View {
    let items: [T]
    let title: String
    @State var item: T
    var callback: ((T) -> Void)
    
    var body: some View {
        VStack() {
            MenuButton(title) {
                ForEach(items, id: \.self) { item in
                    Button {
                        callback(item)
                    } label: {
                        HStack {
                            Text("\(item.value)")
                        }
                    }
                }
            }
            .menuButtonStyle(DefaultMenuButtonStyle())
            .padding(0)
            .foregroundColor(.white)
        }
    }
}

struct TemperatureSliderView: View {
    @Binding var temperature: String
    @State private var progress: Float = 0.5
    @State private var change: String = "0.5"
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack {
            HStack {
                Text(Localization.CurrentTemperature.localized)
                Text(change)
                    .frame(width: 30)
            }
            Slider(value: $progress) {
                
            } minimumValueLabel: {
                Text("0.0")
            } maximumValueLabel: {
                Text("2.0")
            }.padding(.horizontal)
                .frame(width: 200)
            HStack {
                Text("准确性")
                    .font(.caption)
                Spacer()
                Text("想象力")
                    .font(.caption)
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .onChange(of: progress) { newValue in
            let formattedValue = String(format: "%.1f", newValue * 2)
            change = formattedValue
            
        }
        .onAppear {
            if let gpt = viewModel.currentConversation?.chatGPT {
                progress = Float(gpt.temperature / 2)
                let formattedValue = String(format: "%.1f", progress * 2)
                change = formattedValue
            }
        }
        .onDisappear {
            viewModel.currentConversation?.chatGPT?.temperature = Double(progress * 2)
            viewModel.updateConversation(sesstion: viewModel.currentConversation)
            temperature = change
        }
    }
}

