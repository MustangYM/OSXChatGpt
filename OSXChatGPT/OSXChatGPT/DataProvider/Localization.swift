//
//  Localization.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/4/23.
//

import Foundation
import SwiftUI


enum Localization {
    case newChat
    case prompt(_ text: String)
    case editRemark
    case deleteSession
    case EditConversationRemark
    case EnterRemark
    case fasterResponse
    case PromptLibrary
    case NoLoginRequired
    case NoMonthlyFee
    case BetterApplication
    case adMovie
    case adWebsite
    case UpdateAPIKey
    case EnterAPIKey
    case EnterYourAPIKey
    case YouNeedApiKey
    case GetYourAPIKey
    case Cancel
    case Save
    case TheAppWillConnectOpenAIServer
    case deleteMessage
    case copyMessage
    case ParameterAdjustment
    case TemperatureT(_ text: String)
    case ModelT(_ text: String)
    case ContextT(_ text: String)
    case Answer
    case Prompts
    case ClearMessage
    case StopAnswer
    case Empty
    case CurrentTemperature
    case RemoveShortcuts
    case AddShortcuts
    case DeleteData
    case PleaseClickUpperRightAddCustomPrompt
    case SelectPrompt
    case Confirm
    case Library
    case DefaultNoPrompt
    case CurrentSelectPrompt
    case NoPromptToLibraryAdd
    case SelectOnlyOnePromptPerSession
    case CustomAdd
    case Title
    case Required
    case Author
    case ShareYourPromptToLibrary
    case ShareOrNot
    case AnswerStream
    case AnswerOneTime
    case Setting
    case HideDynamicBackground
    case DisplayDynamicBackground
    case Displayed
    case Hidden
    
    var localized: String {
        switch self {
        case .newChat:
            return String(format: NSLocalizedString("newChat", comment: ""))
        case .prompt(let t):
            return String(format: NSLocalizedString("Prompt", comment: ""), t)
        case .editRemark:
            return String(format: NSLocalizedString("editRemark", comment: ""))
        case .deleteSession:
            return String(format: NSLocalizedString("deleteSession", comment: ""))
        case .EditConversationRemark:
            return String(format: NSLocalizedString("EditConversationRemark", comment: ""))
        case .EnterRemark:
            return String(format: NSLocalizedString("EnterRemark", comment: ""))
        case .fasterResponse:
            return String(format: NSLocalizedString("FasterResponse", comment: ""))
        case .PromptLibrary:
            return String(format: NSLocalizedString("PromptLibrary", comment: ""))
        case .NoLoginRequired:
            return String(format: NSLocalizedString("NoLoginRequired", comment: ""))
        case .NoMonthlyFee:
            return String(format: NSLocalizedString("NoMonthlyFee", comment: ""))
        case .BetterApplication:
            return String(format: NSLocalizedString("BetterApplication", comment: ""))
        case .adMovie:
            return String(format: NSLocalizedString("adMovie", comment: ""))
        case .adWebsite:
            return String(format: NSLocalizedString("adWebsite", comment: ""))
        case .UpdateAPIKey:
            return String(format: NSLocalizedString("UpdateAPIKey", comment: ""))
        case .EnterAPIKey:
            return String(format: NSLocalizedString("EnterAPIKey", comment: ""))
        case .EnterYourAPIKey:
            return String(format: NSLocalizedString("EnterYourAPIKey", comment: ""))
        case .YouNeedApiKey:
            return String(format: NSLocalizedString("YouNeedApiKey", comment: ""))
        case .GetYourAPIKey:
            return String(format: NSLocalizedString("GetYourAPIKey", comment: ""))
        case .Cancel:
            return String(format: NSLocalizedString("Cancel", comment: ""))
        case .Save:
            return String(format: NSLocalizedString("Save", comment: ""))
        case .TheAppWillConnectOpenAIServer:
            return String(format: NSLocalizedString("TheAppWillConnectOpenAIServer", comment: ""))
        case .deleteMessage:
            return String(format: NSLocalizedString("deleteMessage", comment: ""))
        case .copyMessage:
            return String(format: NSLocalizedString("copyMessage", comment: ""))
        case .ParameterAdjustment:
            return String(format: NSLocalizedString("ParameterAdjustment", comment: ""))
        case .TemperatureT(let t):
            return String(format: NSLocalizedString("TemperatureT", comment: ""), t)
        case .ModelT(let t):
            return String(format: NSLocalizedString("ModelT", comment: ""), t)
        case .ContextT(let t):
            return String(format: NSLocalizedString("ContextT", comment: ""), t)
        case .Answer:
            return String(format: NSLocalizedString("Answer", comment: ""))
        case .Prompts:
            return String(format: NSLocalizedString("Prompts", comment: ""))
        case .ClearMessage:
            return String(format: NSLocalizedString("ClearMessage", comment: ""))
        case .StopAnswer:
            return String(format: NSLocalizedString("StopAnswer", comment: ""))
        case .Empty:
            return String(format: NSLocalizedString("Empty", comment: ""))
        case .CurrentTemperature:
            return String(format: NSLocalizedString("CurrentTemperature", comment: ""))
        case .RemoveShortcuts:
            return String(format: NSLocalizedString("RemoveShortcuts", comment: ""))
        case .AddShortcuts:
            return String(format: NSLocalizedString("AddShortcuts", comment: ""))
        case .DeleteData:
            return String(format: NSLocalizedString("DeleteData", comment: ""))
        case .PleaseClickUpperRightAddCustomPrompt:
            return String(format: NSLocalizedString("PleaseClickUpperRightAddCustomPrompt", comment: ""))
        case .SelectPrompt:
            return String(format: NSLocalizedString("SelectPrompt", comment: ""))
        case .Confirm:
            return String(format: NSLocalizedString("Confirm", comment: ""))
        case .Library:
            return String(format: NSLocalizedString("Library", comment: ""))
        case .DefaultNoPrompt:
            return String(format: NSLocalizedString("DefaultNoPrompt", comment: ""))
        case .CurrentSelectPrompt:
            return String(format: NSLocalizedString("CurrentSelectPrompt", comment: ""))
        case .NoPromptToLibraryAdd:
            return String(format: NSLocalizedString("NoPromptToLibraryAdd", comment: ""))
        case .SelectOnlyOnePromptPerSession:
            return String(format: NSLocalizedString("SelectOnlyOnePromptPerSession", comment: ""))
        case .CustomAdd:
            return String(format: NSLocalizedString("CustomAdd", comment: ""))
        case .Title:
            return String(format: NSLocalizedString("Title", comment: ""))
        case .Required:
            return String(format: NSLocalizedString("Required", comment: ""))
        case .Author:
            return String(format: NSLocalizedString("Author", comment: ""))
        case .ShareYourPromptToLibrary:
            return String(format: NSLocalizedString("ShareYourPromptToLibrary", comment: ""))
        case .ShareOrNot:
            return String(format: NSLocalizedString("ShareOrNot", comment: ""))
        case .AnswerStream:
            return String(format: NSLocalizedString("AnswerStream", comment: ""))
        case .AnswerOneTime:
            return String(format: NSLocalizedString("AnswerOneTime", comment: ""))
        case .Setting:
            return String(format: NSLocalizedString("Setting", comment: ""))
        case .HideDynamicBackground:
            return String(format: NSLocalizedString("HideDynamicBackground", comment: ""))
        case .DisplayDynamicBackground:
            return String(format: NSLocalizedString("DisplayDynamicBackground", comment: ""))
        case .Displayed:
            return String(format: NSLocalizedString("Displayed", comment: ""))
        case .Hidden:
            return String(format: NSLocalizedString("Hidden", comment: ""))
        }
        
    }
    
}




