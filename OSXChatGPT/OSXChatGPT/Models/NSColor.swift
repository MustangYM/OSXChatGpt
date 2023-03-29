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
    
    convenience init(hex: String, alpha: CGFloat = 1) {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func randomColor() -> NSColor {
        let r = CGFloat(arc4random_uniform(256))
        let g = CGFloat(arc4random_uniform(256))
        let b = CGFloat(arc4random_uniform(256))
        return NSColor(r: r, g: g, b: b)
    }
    
    func toHexString() -> String {
        
        
        
        let redValue = Int(self.redComponent * 255)
        let greenValue = Int(self.greenComponent * 255)
        let blueValue = Int(self.blueComponent * 255)
        let hexString = String(format: "#%02X%02X%02X", redValue, greenValue, blueValue)
        return hexString
    }
    
}
