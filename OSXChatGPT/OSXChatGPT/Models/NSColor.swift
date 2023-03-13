//
//  Color.swift
//  OSXChatGPT
//
//  Created by MustangYM on 2023/3/13.
//

import Foundation
import AppKit
import SwiftUI

extension NSColor {
    func toColor() -> Color {
        return Color(self)
    }
    
    convenience init(r : CGFloat, g : CGFloat, b : CGFloat, alpha: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    static func randomColor() -> NSColor {
        let r = CGFloat(arc4random_uniform(256))
        let g = CGFloat(arc4random_uniform(256))
        let b = CGFloat(arc4random_uniform(256))
        return NSColor(r: r, g: g, b: b)
    }
}
