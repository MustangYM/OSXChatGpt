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
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
//            ContentView().environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext).environmentObject(viewModel)
        }
    }
}
