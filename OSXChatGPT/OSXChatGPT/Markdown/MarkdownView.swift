//
//  Markdown.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/12.
//

import SwiftUI


struct MarkdownView: View {
    private let content: String
    init(_ content: String) {
        self.content = content
    }
    
    public func decorate(_ markdown: String) -> String {
        let components = markdown.components(separatedBy: "```")
        var output = ""

        for (index, component) in components.enumerated() {
            guard index % 2 != 0 else {
                output.append(component)
                continue
            }

            var code = component.trimmingCharacters(in: .whitespacesAndNewlines)
//            let aa = highlighter.highlight(code)
//            code = highlighter.highlight(code)
            output.append(code)
        }

        return output
    }
    
    
    
    var body: some View {
        Text("hello")
    }
}
