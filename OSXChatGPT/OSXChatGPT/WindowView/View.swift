//
//  View.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI

extension View {
    func usePreferredContentSize() -> some View {
        frame(
            minWidth: 400, idealWidth: 500, maxWidth: .infinity,
            minHeight: 300, idealHeight: 350, maxHeight: .infinity,
            alignment: .center
        )
    }
}

