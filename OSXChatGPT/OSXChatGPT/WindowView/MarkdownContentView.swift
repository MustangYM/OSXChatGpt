import MarkdownUI
import SwiftUI

struct YYThemeOption: Hashable {
  let name: String
  let theme: Theme

  static func == (lhs: YYThemeOption, rhs: YYThemeOption) -> Bool {
    lhs.name == rhs.name
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.name)
  }

  static let basic = YYThemeOption(name: "Basic", theme: .basic)
  static let docC = YYThemeOption(name: "DocC", theme: .docC)
  static let gitHub = YYThemeOption(name: "GitHub", theme: .gitHub)
}

struct MarkdownContentView<Content: View>: View {
  private let themeOptions: [YYThemeOption]
  private let about: MarkdownContent?
  private let content: Content

  @State private var themeOption = YYThemeOption(name: "Basic", theme: .basic)

  init(
    themeOptions: [YYThemeOption] = [.gitHub, .docC, .basic],
    @ViewBuilder content: () -> Content
  ) {
    self.themeOptions = themeOptions
    self.about = nil
    self.content = content()
  }

  init(
    themeOptions: [YYThemeOption] = [.gitHub, .docC, .basic],
    @MarkdownContentBuilder about: () -> MarkdownContent,
    @ViewBuilder content: () -> Content
  ) {
    self.themeOptions = themeOptions
    self.about = about()
    self.content = content()
  }

  var body: some View {
    Form {
      self.content
        .markdownTheme(self.themeOption.theme)
        .listRowBackground(self.themeOption.theme.textBackgroundColor)
        .id(self.themeOption.name)
    }
    .onAppear {
      self.themeOption = self.themeOptions[1]
    }
  }
}


