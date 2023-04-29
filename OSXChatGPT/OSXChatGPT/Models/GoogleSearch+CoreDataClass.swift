//
//  GoogleSearch+CoreDataClass.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/28.
//
//

import Foundation
import CoreData

enum GoogleSearchDate: Int16 {
    case unlimited = 0  //无限制
    case oneWeak    // 一周内
    case oneMonth   // 一月内
    case sixMonth   // 六月内
    case oneYears   // 一年内
    var value: String {
        switch self {
        case .unlimited:
            return ""
        case .oneWeak:
            return "w1"
        case .oneMonth:
            return "m1"
        case .sixMonth:
            return "m6"
        case .oneYears:
            return "y1"
        }
    }
}


public class GoogleSearch: NSManagedObject {
    var dateType: GoogleSearchDate {
        get {
            return GoogleSearchDate(rawValue: dateRestrict) ?? .unlimited
        }
        set {
            dateRestrict = newValue.rawValue
        }
    }
    
    
    var baseUrl: String = "https://customsearch.googleapis.com/customsearch/v1"
    var url: String?  {
        var newUrl = baseUrl
        if ChatGPTManager.shared.googleSearchEngineID.isEmpty {
            return nil
        }
        newUrl += "?cx=\(ChatGPTManager.shared.googleSearchEngineID)"
        guard let searchText = search else { return nil }
        newUrl += "&q=\(searchText)"
        newUrl += "&dateRestrict=\(dateType.value)"
        if ChatGPTManager.shared.googleSearchApiKey.isEmpty {
            return nil
        }
        newUrl += "&key=\(ChatGPTManager.shared.googleSearchApiKey)"
        let allowedCharacters = CharacterSet.urlQueryAllowed
        guard let encodedStr = newUrl.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return  nil}
        return encodedStr
    }
}
