//
//  MarkdownTheme.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/12.
//

import SwiftUI


public struct MarkdownTheme {
    public var font: Font
    public var plainTextColor: Color
    public var backgroundColor: Color
    public var blockBackgroundColor: Color
    public var tokenColors: [MarkdownTokenType: Color]
    public init(font: Font,
                plainTextColor: Color,
                blockBackgroundColor: Color,
                tokenColors: [MarkdownTokenType: Color],
                backgroundColor: Color = Color.white.opacity(0.12)) {
        self.font = font
        self.plainTextColor = plainTextColor
        self.tokenColors = tokenColors
        self.backgroundColor = backgroundColor
        self.blockBackgroundColor = blockBackgroundColor
    }
}
