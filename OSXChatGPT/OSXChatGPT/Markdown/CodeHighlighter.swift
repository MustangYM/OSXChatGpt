//
//  MarkdownCodeHighlighter.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/15.
//

import Foundation

struct CodeHighlighter<Format: MarkdownOutputFormat> {
    private let format: Format
    private var grammar: Grammar = SwiftGrammar()
    private let tokenizer = Tokenizer()
    init(format: Format) {
        self.format = format
    }
    
    public func text(_ text: String) -> Format.Builder.Output {
        var builder = format.makeBuilder()
        
        
        return builder.build()
        
    }
    
    /// Highlight the given code, returning output as specified by the
    /// syntax highlighter's `Format`.
    public func highlight(_ code: String) -> Format.Builder.Output {
        var builder = format.makeBuilder()
        var state: (token: String, tokenType: MarkdownTokenType?)?

        func handle(_ token: String, ofType type: MarkdownTokenType?, trailingWhitespace: String?) {
            guard let whitespace = trailingWhitespace else {
                state = (token, type)
                return
            }
            builder.addToken(token, ofType: type)
            builder.addWhitespace(whitespace)
            state = nil
        }

        for segment in tokenizer.segmentsByTokenizing(code, using: grammar) {
            let token = segment.tokens.current
            let whitespace = segment.trailingWhitespace

            guard !token.isEmpty else {
                whitespace.map { builder.addWhitespace($0) }
                continue
            }

            let tokenType = typeOfToken(in: segment)

            guard var currentState = state else {
                handle(token, ofType: tokenType, trailingWhitespace: whitespace)
                continue
            }

            guard currentState.tokenType == tokenType else {
                builder.addToken(currentState.token, ofType: currentState.tokenType)
                handle(token, ofType: tokenType, trailingWhitespace: whitespace)
                continue
            }

            currentState.token.append(token)
            handle(currentState.token, ofType: tokenType, trailingWhitespace: whitespace)
        }

        if let lastState = state {
            builder.addToken(lastState.token, ofType: lastState.tokenType)
        }

        return builder.build()
    }

    private func typeOfToken(in segment: Segment) -> MarkdownTokenType? {
        let rule = grammar.syntaxRules.first { $0.matches(segment) }
        return rule?.tokenType
    }
}
private extension MarkdownBuilder {
    mutating func addToken(_ token: String, ofType type: MarkdownTokenType?) {
        if let type = type {
            addToken(token, ofType: type)
        } else {
            addPlainText(token)
        }
    }
}
