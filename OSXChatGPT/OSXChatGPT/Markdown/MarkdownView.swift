//
//  Markdown.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/12.
//

import SwiftUI


struct MarkdownView: View {
    private let theme: MarkdownTheme
    private let textModel: [MessageText]
    private let highlighter: CodeHighlighter<MarkdownAttTextBuilder>
    
    init(_ textModel: [MessageText], theme: MarkdownTheme) {
        self.textModel = textModel
        self.theme = theme
        highlighter = CodeHighlighter(format: MarkdownAttTextBuilder(theme: theme))
        self.textModel.forEach { model in
            if model.textType == .code {
                model.attString = highlighter.highlight(model.text ?? "")
            }
        }
    }
    
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(textModel, id: \.id) { model in
                if model.textType == .code {
                    HStack(spacing: 15) {
                        Text(model.attString)
                            .font(theme.font)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .lineSpacing(1.5)
                            .minimumScaleFactor(1)

                        Spacer()
                    }.allowsHitTesting(false)
                    .background(theme.backgroundColor)
                    .cornerRadius(10)
                }else {
                    Text(model.text ?? "")
                        .font(theme.font)
                        .lineSpacing(1.5)
                        .foregroundColor(theme.plainTextColor)
                }
            }
        }
//        VStack(alignment: .leading, spacing: 15) {
//            ForEach(textModel, id: \.id) { element in
//                if element.type == .code {
////                    ScrollView(.horizontal) {//开启水平滚动，会导致列表无法滚动
////                    }
//                    HStack(spacing: 15) {
//                        Text(element.attText)
//                            .font(theme.font)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .padding()
//                            .lineSpacing(1.5)
//                            .minimumScaleFactor(1)
//
//                        Spacer()
//                    }.allowsHitTesting(false)
//                    .background(theme.backgroundColor)
//                    .cornerRadius(10)
//
//                }else {
//                    Text(element.text)
//                        .font(theme.font)
//                        .lineSpacing(1.5)
//                        .foregroundColor(theme.plainTextColor)
//                }
//            }
//        }
    }
    
//    private func generateContent() -> [MessageTextModel] {
//        var array: [MessageTextModel] = []
//        if !content.contains("```") {
//            let model = MessageTextModel(type: .text, text: content)
//            array.append(model)
//        }else {
//            let components = content.components(separatedBy: "```")
//            var idx: Int = 0// 0: code， 1: text
//            for (index, str) in components.enumerated() {
//                if index == 0 {
//                    if (content.hasPrefix("```")) {
//                        idx = 0
//                    }else {
//                        idx = 1
//                    }
//                    if idx == 0 {
//                        var model = createMessageCodeModel(text: String(str))
//                        model.attText = highlighter.highlight(model.text)
//                        array.append(model)
//                    }else {
//                        let content = str.trimmingCharacters(in: .whitespacesAndNewlines)
//                        let model = MessageTextModel(type: .text, text: content)
//                        array.append(model)
//                    }
//                    if idx == 0 {
//                        idx = 1
//                    }else {
//                        idx = 0
//                    }
//
//                }else {
//                    if idx == 0 {
//                        var model = createMessageCodeModel(text: String(str))
//                        model.attText = highlighter.highlight(model.text)
//                        array.append(model)
//                    }else {
//                        let content = str.trimmingCharacters(in: .whitespacesAndNewlines)
//                        let model = MessageTextModel(type: .text, text: content)
//                        array.append(model)
//                    }
//                    if idx == 0 {
//                        idx = 1
//                    }else {
//                        idx = 0
//                    }
//                }
//
//            }
//        }
//        return array
//    }
//
//    private func createMessageCodeModel(text: String) -> MessageTextModel {
//        let lines = text.components(separatedBy: "\n")
//        let secondLine = lines[0]
//        var content = String(text)
//        let startIndex = text.index(text.startIndex, offsetBy: 0)
//        let endIndex = text.index(text.startIndex, offsetBy: secondLine.count)
//        let range = startIndex..<endIndex
//        content = text.replacingCharacters(in: range, with: "")
//        content = content.trimmingCharacters(in: .whitespacesAndNewlines)
//        var model = MessageTextModel(type: .code, text: content)
//        let head = secondLine.trimmingCharacters(in: .whitespacesAndNewlines)
//        model.headText = head
//        return model
//    }
}
