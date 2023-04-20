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
    @State private var temperature: String = ""
    @State private var model: String = ""
    @State private var context: String = ""
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isAnswerTypeTrue = ChatGPTManager.shared.answerType.valueBool
    var body: some View {
        HStack {
            MenuButton("参数调节") {
                Button("温度调节(\(temperature))") {
                    showDragView.toggle()
                }
                .padding(.leading, 0)
                
                BrowserView(items: ChatGPTModel.allCases, title: "模型(\(model))", item: viewModel.currentConversation?.chatGPT?.modelType ?? .gpt35turbo) { model in
                    viewModel.currentConversation?.chatGPT?.modelType = model
                    viewModel.updateConversation(sesstion: viewModel.currentConversation)
                    self.model = model.value
                }
                .padding(.leading, 0)
                .frame(width: 100)
                
                BrowserView(items: ChatGPTContext.allCases, title: "上下文(\(context)组对话)", item: viewModel.currentConversation?.chatGPT?.context ?? .context3) { model in
                    viewModel.currentConversation?.chatGPT?.context = model
                    viewModel.updateConversation(sesstion: viewModel.currentConversation)
                    context = model.value
                }
                .padding(.leading, 0)
                .frame(width: 70)
                
            }
            .padding(.leading, 0)
            .frame(width: 85)
            .popover(isPresented: $showDragView, arrowEdge: .top) {
                TemperatureSliderView(temperature: $temperature).environmentObject(viewModel)
            }
            
            BrowserView(items: ChatGPTAnswerType.allCases, title: "应答", item: ChatGPTManager.shared.answerType) { model in
                ChatGPTManager.shared.answerType = model
            }
            
            .frame(width: 60)

            Button("修饰语") {
                showPopover.toggle()
            }
            .popover(isPresented: $showPopover) {
                AIPromptPopView(showInputView: $showInputView, showPopover: $showPopover).environmentObject(viewModel)
            }

            
            Button("清空消息") {
                viewModel.messages.removeAll()
                viewModel.deleteAllMessage(sesstionId: viewModel.currentConversation?.sesstionId ?? "")
                viewModel.updateConversation(sesstionId: viewModel.currentConversation?.sesstionId ?? "", message: nil)
            }
            
            Spacer()
            if viewModel.showStopAnswerBtn {
                Button("停止生成") {
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
            let formattedValue = viewModel.currentConversation?.chatGPT?.temperatureValue ?? "空"
            self.temperature = formattedValue
            
            self.model = viewModel.currentConversation?.chatGPT?.modelType.value ?? "空"
            self.context = viewModel.currentConversation?.chatGPT?.context.value ?? "空"
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

struct TemperatureSliderView: View {
    @Binding var temperature: String
    @State private var progress: Float = 0.5
    @State private var change: String = "0.5"
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack {
            HStack {
                Text("当前温度：")
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
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .onChange(of: progress) { newValue in
            print("aaaa\(newValue)")
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

