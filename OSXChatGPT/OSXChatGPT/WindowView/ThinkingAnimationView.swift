//
//  ThinkingAnimationView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/15.
//

import SwiftUI

struct ThinkingAnimationView: View {
    private let time = 0.15
    var body: some View {
        HStack(spacing: 6) {
//            ThinkingAnimationFirstCircle(color: NSColor(r: 224, g: 87, b: 114).toColor())
            ThinkingAnimationCircle(delay: 0, color: NSColor(r: 224, g: 87, b: 114).toColor(), ratio: 1.3)
            ThinkingAnimationCircle(delay: time, color: NSColor(r: 196, g: 107, b: 145).toColor(), ratio: 1.4)
            ThinkingAnimationCircle(delay: time*2, color: NSColor(r: 171, g: 118, b: 170).toColor(), ratio: 1.45)
            ThinkingAnimationCircle(delay: time*3, color: NSColor(r: 116, g: 129, b: 216).toColor(), ratio: 1.5)
            ThinkingAnimationCircle(delay: time*4, color: NSColor(r: 96, g: 130, b: 229).toColor(), ratio: 1.55)
            ThinkingAnimationCircle(delay: time*5, color: NSColor(r: 80, g: 130, b: 238).toColor(), ratio: 1.6)
            Spacer()
        }.padding(.leading, 13)
        .frame(width: 100, height: 15)
        .onAppear() {
            
        }
    }
}

struct ThinkingAnimationCircle: View {
    @State private var thinking = true
    var delay: CGFloat
    var color: Color
    var ratio: CGFloat
    var body: some View {
        Circle()
            .fill(color)
            .opacity(thinking ? 0.4 : 1.0)
            .frame(width: thinking ? 8 : (ratio * 8), height: thinking ? 8 : (ratio * 8))
            .padding(.trailing, thinking ? ((ratio * 8) - 8) : 0)
            .animation(.easeInOut(duration: 0.8).delay(delay))
            .onAppear { animate() }
    }
    
    func animate() {
        thinking.toggle()
        Timer.scheduledTimer(withTimeInterval: 0.15 * 6, repeats: true) { timer in
            thinking.toggle()
        }
    }
}


struct ThinkingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ThinkingAnimationView()
    }
}
