//
//  PluginPopView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/7/11.
//

import SwiftUI
import SimpleToast

class PluginSelectViewModel: ObservableObject, Identifiable {
    @Published var plugin: PluginAPIInstall
    @Published var isMySelect: Bool
    init(plugin: PluginAPIInstall) {
        self.plugin = plugin
        self.isMySelect = false
    }
    class func createDatas(_ plugins: [PluginAPIInstall]) -> [PluginSelectViewModel] {
        var arr : [PluginSelectViewModel] = []
        plugins.forEach { plu in
            arr.append(PluginSelectViewModel(plugin: plu))
        }
        return arr
    }
}


struct PluginToolView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showPluginView: Bool
    @Binding var isDisabledPlugin: Bool
    var body: some View {
        Button {
            showPluginView.toggle()
        } label: {
            GeometryReader { geometry in
                if viewModel.currentPlugins.count > 0 {
                    HStack(alignment: .center, spacing: 5) {
                        ForEach(viewModel.currentPlugins) { plugin in
                            AsyncImage(url: URL(string: plugin.logo_url ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 16, height: 16)
                            .cornerRadius(2)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(isDisabledPlugin ? 0.6 : 1)
                }else {
                    Text("No Plugin")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(isDisabledPlugin ? 0.6 : 1)
                }
            }
        }

        .frame(width: 75, height: 22)
        .disabled(isDisabledPlugin)
        .onAppear{
            viewModel.refreshCurrentPlugins()
        }
    }
}


struct PluginPopView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var plugins: [PluginSelectViewModel]
    @State private var toastOptions: SimpleToastOptions = SimpleToastOptions(alignment: .center, hideAfter: 2.5, backdrop: nil, animation: nil, modifierType: .fade, dismissOnTap: true)
    @State private var isShowToast: Bool = false
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("取消")
                }.padding()
                Spacer()
                
                Button {
                    var select: [PluginAPIInstall] = []
                    plugins.forEach { viewM in
                        if viewM.isMySelect {
                            select.append(viewM.plugin)
                        }
                    }
                    viewModel.updateCurrentPlugins(plugins: select)
                    viewModel.refreshCurrentPlugins()
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("确定")
                }.padding()
                
            }
            .padding(.top, 16)
            .frame(height: 35)
            .frame(maxWidth: .infinity)
            .background(.white)
            
            List {
                ForEach(plugins, id: \.plugin.id) { plugin in
                    Toggle(isOn: Binding(get: { plugins[getIndex(for: plugin)].isMySelect }, set: { newValue in
                        if newValue == true {
                            if plugins.filter( {$0.isMySelect == true }).count >= 3 {
                                self.isShowToast = true
                                return
                            }
                        }
                        plugin.isMySelect = newValue;
                        plugins[getIndex(for: plugin)] = plugin
                    }))  {
                        HStack {
                            AsyncImage(url: URL(string: plugin.plugin.logo_url ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 35, height: 35)
                            .cornerRadius(5)
                            VStack(alignment: .center) {
                                HStack {
                                    Text(plugin.plugin.name_for_human ?? "")
                                        .font(Font.system(size: 14))
                                        Spacer()
                                }
                                    .padding(.bottom, 1)
                                Text(plugin.plugin.description_for_human ?? "")
                                    .font(Font.system(size: 12))
                            }
                            .frame(maxWidth: .infinity, minHeight: 45, maxHeight: 45, alignment: .leading)
                            
                        }
                    }
                    .padding(5)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            .padding(.top, 1)
            .frame(width: 380, height: 500)
            
            .onAppear {

            }
        }
        .simpleToast(isPresented: $isShowToast, options: self.toastOptions, content: {
            VStack {
                Text("最多选三个插件")
                    .padding()
                    .foregroundColor(.white)
                    .background(.black.opacity(0.9))
                    .cornerRadius(5)
            }
            .padding()
            
        })
    }
    
    func getIndex(for plugin: PluginSelectViewModel) -> Int {
        plugins.firstIndex(where: { $0.plugin.id == plugin.plugin.id })!
    }
}

//struct PluginPopView_Previews: PreviewProvider {
//    static var previews: some View {
//        PluginPopView()
//    }
//}
