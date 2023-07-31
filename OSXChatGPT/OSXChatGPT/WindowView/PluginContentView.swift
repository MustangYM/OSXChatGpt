//
//  PluginContentView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/6/20.
//

import SwiftUI
import SimpleToast

struct PluginContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @StateObject var pluginViewModel = PluginViewModel()
    @State private var toastOptions: SimpleToastOptions = SimpleToastOptions(alignment: .center, hideAfter: 2.5, backdrop: nil, animation: nil, modifierType: .fade, dismissOnTap: true)
    @State private var isShowToast: Bool = false
    @State private var errorToast: String = ""
    @State private var isShowing: Bool = false
    var body: some View {
        VStack {
            GeometryReader { geometry in
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        pluginViewModel.reloadAllManifestes()
                    } label: {
                        Text("更新插件")
                    }
                    .padding()

                }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.white)
                
            }.frame(height: 40)
                .padding(.top, 1)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 230), spacing: 16)], alignment: .leading, spacing: 16) {
                    ForEach(pluginViewModel.pluginList) { item in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                                .frame(height: 165)
                            PluginItemView(manifest: item, pluginViewModel: pluginViewModel, showToast: { err in
                                self.isShowToast = false
                                self.toastOptions = self.createNewToastOptions()
                                self.errorToast = err
                                self.isShowToast = true
                            }).environmentObject(viewModel)
                        }
                    }
                }
            }
            .padding()
            Spacer()
        }
        .simpleToast(isPresented: $isShowToast, options: self.toastOptions, content: {
            VStack {
                Text(self.errorToast)
                    .padding()
                    .foregroundColor(.white)
                    .background(.black.opacity(0.9))
                    .cornerRadius(5)
            }
            .padding()
            
        })
        
        .onAppear {
            
        }
        
    }
    private func createNewToastOptions() -> SimpleToastOptions {
        return SimpleToastOptions(alignment: .center, hideAfter: 2.5, backdrop: nil, animation: nil, modifierType: .fade, dismissOnTap: true)
    }
}

struct PluginItemView: View {
    let manifest: PluginManifest
    let pluginViewModel: PluginViewModel
    var showToast: (String) -> ()
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var isShowLoading: Bool = false
    @State private var downloadProgress: Double = 0.0
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        AsyncImage(url: URL(string: manifest.logo_url ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)
                        VStack(alignment: .leading) {
                            Text(manifest.name_for_human ?? manifest.name_for_model ?? "NULL")
                                .textSelection(.enabled)
                            HStack {
                                Button {
                                    if manifest.install == nil {
                                        installPlugin(manifest: manifest)
                                    }else if manifest.install?.schema_version != manifest.schema_version {
                                        installPlugin(manifest: manifest)
                                    } else {
                                        uninstall(manifest: manifest)
                                    }
                                } label: {
                                    HStack {
                                        if manifest.install == nil {
                                            Text("安装")
                                                .foregroundColor(.white)
                                            if isShowLoading {
                                                PluginDownloadProgressView(circleBackdropColor: .white.opacity(0.5), circleForegroundColor: .white, progress: $downloadProgress)
                                                    .frame(width: 15, height: 15)
                                            }else {
                                                Image(systemName: "arrow.down.circle.fill")
                                                    .foregroundColor(.white)
                                                    .frame(width: 15, height: 15)
                                            }
                                        }else if manifest.install?.schema_version != manifest.schema_version {
                                            Text("更新")
                                                .foregroundColor(.white)
                                            Image(systemName: "arrow.clockwise.circle.fill")
                                                .foregroundColor(.white)
                                                .frame(width: 15, height: 15)
                                        } else {
                                            Text("卸载")
                                                .foregroundColor(.white)
                                            Image(systemName: "xmark.bin.circle.fill")
                                                .foregroundColor(.white)
                                                .frame(width: 15, height: 15)
                                        }
                                    }
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .frame(width: 80, height: 30)
                                        .background((manifest.install == nil || manifest.install?.schema_version != manifest.schema_version) ? .blue : .red)
                                }.buttonStyle(PlainButtonStyle())
                                    .frame(width: 80, height: 30)
                                    .cornerRadius(5)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                    Spacer()
                }
                VStack {
                    Text(manifest.description_for_human ?? manifest.description_for_model ?? "")
                        .padding(EdgeInsets(top: 70, leading: 12, bottom: 5, trailing: 12))
                        .textSelection(.enabled)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    func installPlugin(manifest: PluginManifest) {
        if isShowLoading == true {
            return
        }
        downloadProgress = 0
        isShowLoading = true
        pluginViewModel.InstallPlugin(manifest: manifest) { pro in
            self.downloadProgress = Double(pro.completedUnitCount / pro.totalUnitCount)
            print("Progress:\(pro.totalUnitCount), \(pro.completedUnitCount)")
        } complete: { err in
            if let error = err {
                self.installPluginError(err: error)
            }else {
                //成功
                showToast("安装成功")
            }
        }
    }
    func installPluginError(err: String) {
        showToast(err)
        downloadProgress = 0
        isShowLoading = false
    }
    func test() {
        if downloadProgress >= 1 {
            withAnimation {
                isShowLoading = false
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.downloadProgress += 0.1
            self.test()
        }
    }
    func uninstall(manifest: PluginManifest) {
        if let err = pluginViewModel.uninstall(manifest: manifest) {
            showToast(err)
        }else {
            showToast("卸载成功")
            downloadProgress = 0
            isShowLoading = false
        }
    }
}

struct PluginContentView_Previews: PreviewProvider {
    static var previews: some View {
        PluginContentView()
    }
}

struct PluginDownloadProgressView: View {
    let lineWidth: CGFloat = 2
    let circleBackdropColor: Color
    let circleForegroundColor: Color
    @Binding var progress: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()  // Inactive
                    .stroke(lineWidth: lineWidth)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(circleBackdropColor)
                
                Rectangle()
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                    .foregroundColor(circleForegroundColor)
                    .cornerRadius(2)
//                ProgressView()
//                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
//                    .foregroundColor(circleForegroundColor)
                //                        .cornerRadius(2)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(circleForegroundColor)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear)
            }
            
        }
    }
}
