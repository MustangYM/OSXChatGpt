//
//  MarkdownTextAttributesReader.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/14.
//



import SwiftUI

struct MarkdownTextAttributesReader<Content: View>: View {
//  @Environment(\.textStyle) private var textStyle

  private let content: (AttributeContainer) -> Content

  init(@ViewBuilder content: @escaping (_ attributes: AttributeContainer) -> Content) {
    self.content = content
  }

  var body: some View {
    self.content(self.attributes)
  }

  private var attributes: AttributeContainer {
    var attributes = AttributeContainer()
//    self.textStyle._collectAttributes(in: &attributes)
    return attributes
  }
}
