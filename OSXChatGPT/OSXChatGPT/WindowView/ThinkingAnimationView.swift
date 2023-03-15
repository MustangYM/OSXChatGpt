//
//  ThinkingAnimationView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/15.
//

import SwiftUI

struct ThinkingAnimationView: View {
    var body: some View {
        HStack(spacing: 6) {
            ThinkingAnimationFirstCircle(color: NSColor(r: 224, g: 87, b: 114).toColor())
            ThinkingAnimationCircle(delay: 0.0, color: NSColor(r: 224, g: 87, b: 114).toColor())
            ThinkingAnimationCircle(delay: 0.2, color: NSColor(r: 196, g: 107, b: 145).toColor())
            ThinkingAnimationCircle(delay: 0.4, color: NSColor(r: 171, g: 118, b: 170).toColor())
            ThinkingAnimationCircle(delay: 0.6, color: NSColor(r: 131, g: 127, b: 205).toColor())
            ThinkingAnimationCircle(delay: 0.8, color: NSColor(r: 128, g: 109, b: 221).toColor())
            ThinkingAnimationCircle(delay: 1.0, color: NSColor(r: 80, g: 130, b: 238).toColor())
            Spacer()
        }
        .frame(width: 105, height: 15)
        .onAppear() {
            
        }
    }
}


struct ThinkingAnimationFirstCircle: View {
    @State private var thinking = true
    var color: Color
    var body: some View {
        Circle()
            .fill(color)
            .opacity(thinking ? 0.0 : 1)
            .animation(.default.delay(0))
            .frame(width: 10, height: 10)
            .onAppear { animate() }
    }
    
    func animate() {
        thinking.toggle()
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            thinking.toggle()
        }
    }
}
struct ThinkingAnimationCircle: View {
    @State private var thinking = true
    var delay: CGFloat
    var color: Color
    var body: some View {
        Circle()
            .fill(color)
            .opacity(thinking ? 0.0 : 1)
            .animation(.default.delay(delay))
            .frame(width: 8, height: 8)
            .onAppear { animate() }
    }
    
    func animate() {
        thinking.toggle()
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            thinking.toggle()
        }
    }
}


struct ThinkingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ThinkingAnimationView()
    }
}
