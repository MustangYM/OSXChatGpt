//
//  Message+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//
//

import Foundation
import CoreData


public class Message: NSManagedObject {
    var textArray: [MessageTextModel] {
        get {
            guard let text = text else { return [] }
            var array: [MessageTextModel] = []
            if !text.contains("```") {
                let model = MessageTextModel(type: .text, text: text)
                array.append(model)
            }else {
                let components = text.split(separator: "```")
                var idx: Int = 0// 0: code， 1: text
                for (index, str) in components.enumerated() {
                    if index == 0 {
                        if (text.hasPrefix("```")) {
                            idx = 0
                        }else {
                            idx = 1
                        }
                        if idx == 0 {
                            let lines = str.components(separatedBy: "\n")
                            let secondLine = lines[0]
                            var content = String(str)
                            let startIndex = str.index(str.startIndex, offsetBy: 0)
                            let endIndex = str.index(str.startIndex, offsetBy: secondLine.count)
                            let range = startIndex..<endIndex
                            content = str.replacingCharacters(in: range, with: "")
                            var model = MessageTextModel(type: .code, text: content)
                            let head = secondLine.trimmingCharacters(in: .whitespacesAndNewlines)
                            model.headText = head
                            array.append(model)
                        }else {
                            let model = MessageTextModel(type: .text, text: String(str))
                            array.append(model)
                        }
                        if idx == 0 {
                            idx = 1
                        }else {
                            idx = 0
                        }
                        
                    }else {
                        if idx == 0 {
                            let lines = str.components(separatedBy: "\n")
                            let secondLine = lines[0]
                            var content = String(str)
                            let startIndex = str.index(str.startIndex, offsetBy: 0)
                            let endIndex = str.index(str.startIndex, offsetBy: secondLine.count)
                            let range = startIndex..<endIndex
                            content = str.replacingCharacters(in: range, with: "")
                            var model = MessageTextModel(type: .code, text: content)
                            let head = secondLine.trimmingCharacters(in: .whitespacesAndNewlines)
                            model.headText = head
                            array.append(model)
                        }else {
                            let model = MessageTextModel(type: .text, text: String(str))
                            array.append(model)
                        }
                        if idx == 0 {
                            idx = 1
                        }else {
                            idx = 0
                        }
                    }
                    
                }
                
            }
            
            return array
        }
    }
}
