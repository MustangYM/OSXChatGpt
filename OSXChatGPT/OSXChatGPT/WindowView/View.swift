//
//  View.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/11.
//

import SwiftUI

extension View {
    func leftSessionContentSize() -> some View {
        frame(
            minWidth: 250, idealWidth: 250, maxWidth: .infinity,
            minHeight: 300, idealHeight: 350, maxHeight: .infinity,
            alignment: .leading
        )
    }
}

//低于macOS13输入框的背景色
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}
//list背景透明
extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}
