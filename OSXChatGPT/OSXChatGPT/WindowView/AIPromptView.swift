//
//  AIPromptView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/27.
//

import SwiftUI

struct AIPromptDetailView: View {
    let prompt: Prompt
    @StateObject var data: AIPromptViewMdoel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prompt.title ?? "")
                                .font(.headline)
                                .foregroundColor((colorScheme == .dark) ? .white.opacity(0.8) : .white)
                                .padding(.bottom, 6)
                            HStack {
                                Button {
                                    if prompt.type == 3 {
                                        //移除，
                                        prompt.type = 2
                                        data.updatePrompt(prompt: prompt, isToggleOn: false)
                                        presentationMode.wrappedValue.dismiss()
                                    }else {
                                        //添加，
                                        prompt.type = 3
                                        data.updatePrompt(prompt: prompt, isToggleOn: false)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                } label: {
                                    HStack {
                                        if prompt.type == 3 {
                                            Image(systemName: "minus.square")
                                                .resizable()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                                .padding(0)
                                            Text("移除快捷方式")
                                                .padding(0)
                                                .foregroundColor(.white)
                                        }else {
                                            HStack {
                                                Image(systemName: "plus.app")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundColor(.white)
                                                    .padding(0)
                                                Text("添加快捷方式")
                                                    .padding(0)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                                    
                                }
                                .buttonStyle(LinkButtonStyle())
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 0.5)
                                )
                                
                                if prompt.type == 2 {
                                    Button {
                                        data.deletePrompt(prompt: prompt)
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash.slash")
                                                .resizable()
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(.white)
                                                .padding(0)
                                            Text("删除数据")
                                                .padding(0)
                                                .foregroundColor(.white)
                                        }
                                        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                                        
                                    }.buttonStyle(LinkButtonStyle())
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white, lineWidth: 0.5)
                                        )
                                }
                            }
                            
                            
                        }.padding(.leading, 6)
                        Spacer()
                    }.padding(.bottom, 10)
                    ScrollView {
                        HStack() {
                            Text(prompt.prompt ?? "")
                                .font(.subheadline)
                                .foregroundColor((colorScheme == .dark) ? .white.opacity(0.6) : .white)
                                .padding(10)
                            Spacer()
                            
                        }
                        
                    }
                    .frame(width: geometry.size.width - 30, height: geometry.size.height - 120)
                    .background(.white.opacity(0.1))
                    .cornerRadius(5)
                }
                
                if let author = prompt.author {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(author)")
                                .foregroundColor((colorScheme == .dark) ? .white.opacity(0.8) : .white)
                                .font(.system(size: 11))
                                .padding(.top, 5)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .cornerRadius(6)
            .background(
                prompt.color.brightness((self.colorScheme == .dark) ? -0.5 : -0.2)
            )
        }
        .frame(width: 500, height: 350)
        
    }
}



struct AIPromptView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var viewModel: ViewModel
    @StateObject var data = AIPromptViewMdoel()
    @State private var isPresented = false
    @State private var showInputView = false
    
    var titleColor: Color {
        switch colorScheme {
        case .dark:
            return Color.white.opacity(0.9)
        default:
            return Color.black.opacity(0.9)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if data.allPrompts.count > 0 {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(data.allPrompts) { (item) in
                            AIPromptCellView(data: data, item: item)
                        }
                    }
                    .background(Color.clear)
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .frame(width: geometry.size.width, height: geometry.size.height - 50)
                
                .onAppear {
                    
                }
            }else {
                VStack(alignment: .center) {
                    Text("请点击右上角自定义添加新的修饰语")
                }.frame(width: geometry.size.width, height: geometry.size.height - 50)
            }
            
            
        }
        .padding(.top, 1)
        .toolbar {
            Spacer()
            Button(action: {
                showInputView.toggle()
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showInputView) {
            AIPromptInputView(viewModel: data, isPresented: $showInputView)
        }
        
        
    }
}

struct AIPromptCellView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var data: AIPromptViewMdoel
    @State private var isTapped = false
    @State var item: Prompt
        var body: some View {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                if item.type == 3 {
                                    Image(systemName: "checkmark.square")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 0)
                                }else {
                                    Image(systemName: "plus.app")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 0)
                                }
                                
                                Text(item.title ?? "")
                                    .font(.headline)
                                    .foregroundColor((colorScheme == .dark) ? .white.opacity(0.8) : .white)
                                    .padding(.leading, 0)
                                
                            }.padding(.bottom, 6)
                            Text(item.prompt ?? "")
                                .font(.subheadline)
                                .foregroundColor((colorScheme == .dark) ? .white.opacity(0.6) : .white)
                        }.padding(.leading, 2)
                        Spacer()
                    }
                    
                }
                
                if let author = item.author {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(author)")
                                .foregroundColor((colorScheme == .dark) ? .white.opacity(0.8) : .white)
                                .font(.system(size: 11))
                                .padding(.top, 5)
                        }
                        Spacer()
                    }
                }
                
                
            }
            .frame(height: 60)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                item.color.brightness((self.colorScheme == .dark) ? -0.5 : -0.2)
            )
            .cornerRadius(6)
            .onTapGesture {
                self.isTapped.toggle()
            }
            .sheet(isPresented: $isTapped) {
                AIPromptDetailView(prompt: item, data: data)
                    .onTapGesture {
                        isTapped = false
                    }
                
            }
            
        }
}



//struct AIPromptView_Previews: PreviewProvider {
//    static var previews: some View {
//        AIPromptView(sesstionId: nil)
//    }
//}
