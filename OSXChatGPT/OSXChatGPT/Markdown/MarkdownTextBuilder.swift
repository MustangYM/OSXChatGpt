//
//  MarkdownTextBuilder.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/14.
//

import SwiftUI


protocol MarkdownOutputFormat {
    associatedtype Builder: MarkdownBuilder
    func makeBuilder() -> Builder
}

protocol MarkdownBuilder {
    associatedtype Output
    mutating func addToken(_ token: String, ofType type: MarkdownTokenType)
    mutating func addPlainText(_ text: String)
    mutating func addWhitespace(_ whitespace: String)
    mutating func build() -> Output
}


struct MarkdownAttTextBuilder: MarkdownOutputFormat {
    
    var theme: MarkdownTheme

    init(theme: MarkdownTheme) {
        self.theme = theme
    }

    func makeBuilder() -> Builder {
        return Builder(theme: theme)
    }
    
}

extension MarkdownAttTextBuilder {
    struct Builder: MarkdownBuilder {
        typealias Output = AttributedString
        private let theme: MarkdownTheme
        private lazy var font = theme.font
//        private var string = NSMutableAttributedString()
        private var string = AttributedString()
        
        init(theme: MarkdownTheme) {
            self.theme = theme
            
            
        }
        
        mutating func addToken(_ token: String, ofType: MarkdownTokenType) {
            let color = theme.tokenColors[ofType] ?? Color(red: 1, green: 1, blue: 1)
            string.append(token, font: font, color: color)
        }
        
        mutating func addPlainText(_ text: String) {
            string.append(text, font: font, color: theme.plainTextColor)
        }
        
        mutating func addWhitespace(_ whitespace: String) {
            let color = Color(red: 1, green: 1, blue: 1)
            string.append(whitespace, font: font, color: color)
        }
        
        mutating func build() -> AttributedString {
            
            return string
        }
    }
}

private extension AttributedString {
    mutating func append(_ string: String, font: Font, color: Color) {
        var att = AttributeContainer()
        att.font = font
//        att.kern = 1
        att.foregroundColor = color
        
        var aa = AttributedString(string)
        aa.mergeAttributes(att)
        self += aa
    }
}



