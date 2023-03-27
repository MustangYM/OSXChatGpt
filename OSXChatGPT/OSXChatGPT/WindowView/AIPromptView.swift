//
//  AIPromptView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/27.
//

import SwiftUI




struct AIPromptView: View {
    let sesstionId: String? //有则表示在会话中打开
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AIPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AIPromptView(sesstionId: nil)
    }
}
