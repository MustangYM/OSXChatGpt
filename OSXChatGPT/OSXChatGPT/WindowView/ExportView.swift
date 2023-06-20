//
//  ExportView.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/5/9.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit
import CoreGraphics
import AppKit
import SimpleToast


enum MessageExportType :ToolBarMenuProtocol {
    var value: String {
        switch self {
        case .none:
            return ""
        case .PDF:
            return Localization.ExportPDF.localized
        case .txt:
            return Localization.ExportTxt.localized
        }
    }
    case none
    case PDF
    case txt
    
    static var allCases: [MessageExportType] {
        return [.PDF, .txt]
    }
}

class ExportMessageViewModel: ObservableObject, Identifiable {
    @Published var message: Message
    @Published var isMySelect: Bool
    init(message: Message) {
        self.message = message
        self.isMySelect = false
    }
    
    class func createDatas(_ msgs: [Message]) -> [ExportMessageViewModel] {
        var arr : [ExportMessageViewModel] = []
        msgs.forEach { msg in
            arr.append(ExportMessageViewModel(message: msg))
        }
        return arr
        
    }
}

struct ExportView: View {
    let type: MessageExportType
    @State var messages: [ExportMessageViewModel]
    @State private var isSelectAll: Bool = false
    @State private var isExport: Bool = false
    @State private var documentData: Data = Data()
    @State private var isShowToast: Bool = false
    @State private var toastOptions: SimpleToastOptions = SimpleToastOptions(alignment: .center, hideAfter: 2.5, backdrop: nil, animation: nil, modifierType: .fade, dismissOnTap: true)
    @State private var exportMessage: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Toggle(Localization.CheckAll.localized, isOn: Binding(get: {isSelectAll}, set: { newValue, tran in
                    isSelectAll = newValue
                    messages.forEach { msg in
                        msg.isMySelect = newValue
                        messages[getIndex(for: msg)] = msg
                    }
                }))
                    .padding()
                Spacer()
                Button(Localization.Cancel.localized) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding(.trailing, 0)
                Button(type.value) {
                    exportSelectedMessages()
                }
                
                .padding()
                
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.white)
            List {
                ForEach(messages, id: \.message.id) { message in
                        Toggle(isOn: Binding(get: { messages[getIndex(for: message)].isMySelect }, set: { newValue in
                            message.isMySelect = newValue;
                            messages[getIndex(for: message)] = message
                            isSelectAll = messages.allSatisfy { $0.isMySelect }
                        }))  {
                        Text(message.message.text ?? "")
                            .font(Font.system(size: 13, weight: .regular, design: .monospaced))
                            .lineSpacing(1.5)
                            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 80, alignment: .leading)
                    }
                    .padding(5)
                    .background(message.message.role == ChatGPTManager.shared.gptRoleString ? Color.gray.opacity(0.3) : Color.blue.opacity(0.6))
                    .foregroundColor(message.message.role == ChatGPTManager.shared.gptRoleString ? Color.black : .white)
                    .cornerRadius(6)
                }
            }
            
        }
        .frame(width: 600, height: 500)
        
        .onAppear {
            isSelectAll = messages.allSatisfy { $0.isMySelect }
        }
        .fileExporter(isPresented: $isExport, document: ExportDocument(data: self.documentData), contentType: self.createExportDocumentType(), defaultFilename: createExportDocumentName()) { result in
            switch result {
            case .success(_):
                self.exportMessage = Localization.ExportSucceed.localized
                self.isShowToast.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.presentationMode.wrappedValue.dismiss()
                }
                break
            case .failure(_):
                self.exportMessage = Localization.ExportFailure.localized
                self.isShowToast.toggle()
                break
            }
            isExport = false
        }
        .simpleToast(isPresented: $isShowToast, options: self.toastOptions) {
            
        } content: {
            HStack {
                Text(self.exportMessage)
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(Color.white)
            .cornerRadius(10)
        }

        
    }
    
    func getIndex(for message: ExportMessageViewModel) -> Int {
        messages.firstIndex(where: { $0.message.id == message.message.id })!
    }
    func exportSelectedMessages() {
        let selectedMessages = messages.filter { $0.isMySelect }
        if selectedMessages.count == 0 {
            self.exportMessage = Localization.ExportEmptyTip.localized
            self.isShowToast.toggle()
            return
        }
        var content: String = ""
        selectedMessages.forEach { msg in
            if var text = msg.message.text {
                if msg.message.role == ChatGPTManager.shared.gptRoleString {
                    text = "[ChatGPT]\n \(text)"
                }else {
                    text = "[User]\n \(text)"
                }
                if content.count > 0 {
                    content.append("\n\n=======================================================\n\n")
                }
                content.append(text)
            }
        }
        if type == .PDF {
            self.documentData = self.createPDF(chatContent: content).dataRepresentation()!
        }else if type == .txt {
            if let data = content.data(using: .utf8) {
                self.documentData = data
            }
        }
        self.isExport = true
        
    }
    
    func createExportDocumentType() -> UTType {
        if type == .PDF {
            return .pdf
        }else if type == .txt {
            return .plainText
        }
        return .text
    }
    func createExportDocumentName() -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MMddHHmm"
        let dateStr = dformatter.string(from: Date())
        if type == .PDF {
            return "OSXChatGPT_data_\(dateStr).pdf"
        }else if type == .txt {
            return "OSXChatGPT_data_\(dateStr).txt"
        }
        return dateStr
    }
    func createPDF(chatContent: String) -> PDFDocument {
        let pdfDocument = PDFDocument()
        let images = createImageFrom(chatContent: chatContent)
        for (idx, image) in images.enumerated() {
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: idx)
        }
        return pdfDocument
    }
    
    func createImageFrom(chatContent: String) -> [NSImage] {
        let size = CGSize(width: 595.2, height: 841.8)//A4纸张大小
        let view = NSTextView()
        let contentFrame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        view.font = NSFont.systemFont(ofSize: 14)
        view.string = chatContent
        view.maxSize = NSSize(width: contentFrame.width, height: CGFloat(MAXFLOAT))
        view.sizeToFit()
        view.frame = NSRect(x: 0, y: 0, width: size.width, height: view.bounds.height)
        
        if let layoutManager = view.layoutManager, let textContainer = view.textContainer {
            // sizeToFit() 计算不够准确
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            let height = usedRect.size.height
            view.frame = NSRect(x: 0, y: 0, width: size.width, height: height)
        }
        
        
        var images: [NSImage] = []
        let page = view.bounds.size.height / contentFrame.size.height
        var p = Int(page)
        if (page > CGFloat(p)) {
            p += 1
        }
        for index in 0..<p {
            let textContainer = NSText(frame: NSRect(x: 0, y: 0, width: contentFrame.width, height: contentFrame.height))
            view.frame = NSRect(x: 0, y: -(CGFloat(index) * contentFrame.size.height), width: contentFrame.size.width, height: contentFrame.size.height * CGFloat(index + 1))
            textContainer.addSubview(view)
            let container = NSText(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height))
            container.backgroundColor = NSColor.white
            container.addSubview(textContainer)
            let data = container.dataWithPDF(inside: container.bounds)
            if let image = NSImage(data: data) {
                images.append(image)
            }
        }
        return images
    }
    
}



struct ExportDocument: FileDocument {
    var data: Data
    
    init(data: Data = Data()) {
        self.data = data
    }
    
    static var readableContentTypes: [UTType] { [.pdf, .plainText] }
    
    init(configuration: ReadConfiguration) throws {
        self.data = Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: self.data)
    }
}


//struct ExportView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExportView()
//    }
//}
