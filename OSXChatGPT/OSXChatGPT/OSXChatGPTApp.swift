//
//  OSXChatGPTApp.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/5.
//

import SwiftUI

@main
struct OSXChatGPTApp: App {
    @StateObject var viewModel = ViewModel()
    @StateObject var model = ViewModel()
    var body: some Scene {
        WindowGroup {
//            ConversationView()
            ContentView().environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext).environmentObject(viewModel)
                .frame(minWidth: 600, idealWidth: 800, minHeight: 500, idealHeight: 600)
        }
//        .windowStyle(.hiddenTitleBar)
    }
}
