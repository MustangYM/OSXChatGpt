//
//  PluginViewModel.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/6/21.
//

import Foundation
import Yams
import CoreData


class PluginViewModel: ObservableObject {
    
    @Published var pluginList: [PluginManifest] = []
    
    
    init() {
        fetchAllPlugin()
    }
    /// 获取所有插件
    func fetchAllPlugin() {
        var aa: [PluginManifest] = CoreDataManager.shared.fetch("PluginManifest", sorting: nil)
        let remove = aa.filter { $0.name_for_human == nil }
        if remove.count > 0 {
            CoreDataManager.shared.delete(objects: remove)
            aa.removeAll(where: { $0.name_for_human == nil })
            CoreDataManager.shared.saveData()
        }
        pluginList = aa
    }
    
    static func fetchAllInstallPlugins(_ select:[PluginAPIInstall]) -> [PluginSelectViewModel] {
        
        let request: NSFetchRequest<PluginManifest> = PluginManifest.fetchRequest()
        request.predicate = NSPredicate(format: "install != NULL")
        let results: [PluginManifest] = CoreDataManager.shared.fetch(request: request)
        var temp: [PluginSelectViewModel] = []
        results.forEach { manifest in
            if let insta = manifest.install {
                let model = PluginSelectViewModel(plugin: insta)
                if select.contains(where: { $0.name_for_human == insta.name_for_human}) {
                    model.isMySelect = true
                }
                temp.append(model)
            }
        }
        
        return temp
    }
    
    /// 安装插件
    func InstallPlugin(manifest: PluginManifest, progress:@escaping ((Progress) -> Void), complete:@escaping ((String?) -> Void)) {
        guard let api = manifest.api?.url else {
            complete("api URL Error")
            return
        }
        HTTPClient.shared.downloadData(urlStr: api, progress: progress) { resUrl, err in
            if let url = resUrl {
                do {
                    let data = try Data(contentsOf: url)
                    if let content = String(data: data, encoding: .utf8),
                        let json = try Yams.load(yaml: content) as? [String: Any] {
                        self.installPluginToCoreData(manifest: manifest, jsonString: content, json: json)
                        complete(nil)
                        print(json)
                    }else {
                        complete("Install Error")
                    }
                } catch {
                    print("读取文件失败: \(error)")
                    complete("Install Error")
                }
            }else {
                complete("Install Error")
            }
//            print("downloadData reUrl:\(resUrl) \n err:\(err)")
        }
    }
    func uninstall(manifest: PluginManifest) -> String? {
        if let plugin = fetchManifest(name_for_human: manifest.name_for_human) {
            if let install = plugin.install {
                CoreDataManager.shared.delete(object: install)
            }
            plugin.install = nil
            if let index = pluginList.firstIndex(where: { $0.name_for_human == plugin.name_for_human }) {
                pluginList[index] = plugin
            }
            CoreDataManager.shared.saveData()
            return nil
        }else {
            return "uninstall Error"
        }
    }
    private func installPluginToCoreData(manifest: PluginManifest, jsonString: String, json: [String: Any]) {
        let install = PluginAPIInstall(context: CoreDataManager.shared.container.viewContext)
        if let plugin = fetchManifest(name_for_human: manifest.name_for_human) {
            install.schema_version = manifest.schema_version
            install.apiJsonString = jsonString;
            install.logo_url = manifest.logo_url
            install.name_for_human = manifest.name_for_human
            install.description_for_human = manifest.description_for_human
            install.apiJson = json
            plugin.install = install
            if let index = pluginList.firstIndex(where: { $0.name_for_human == plugin.name_for_human }) {
                DispatchQueue.main.async {
                    self.pluginList[index] = plugin
                }
            }
            CoreDataManager.shared.saveData()
        }
        
    }
    func reloadAllManifestes() {
        HTTPClient.getManifests { datas, err in
            if let er = err {
                print("error:\(er)")
                return
            }
            if let jsons = datas as? [[String:Any]] {
                var temp : [PluginManifest] = []
                jsons.forEach { json in
                    let name_for_human = json["name_for_human"] as? String
                    var plugin = self.fetchPlugin(name_for_human: name_for_human ?? "")
                    if plugin?.id == nil {
                        plugin?.id = UUID()
                    }
                    if plugin == nil {
                        plugin = PluginManifest(context: CoreDataManager.shared.container.viewContext)
                        plugin?.id = UUID()
                        plugin?.api = PluginManifestAPI(context: CoreDataManager.shared.container.viewContext)
                        plugin?.auth = PluginManifestAuth(context: CoreDataManager.shared.container.viewContext)
                        
                    }
                    plugin?.setValue(json["schema_version"], forKey: "schema_version")
                    plugin?.setValue(json["name_for_human"], forKey: "name_for_human")
                    plugin?.setValue(json["name_for_model"], forKey: "name_for_model")
                    plugin?.setValue(json["description_for_human"], forKey: "description_for_human")
                    plugin?.setValue(json["description_for_model"], forKey: "description_for_model")
                    plugin?.setValue(json["logo_url"], forKey: "logo_url")
                    plugin?.setValue(json["contact_email"], forKey: "contact_email")
                    plugin?.setValue(json["legal_info_url"], forKey: "legal_info_url")
                    plugin?.api?.setValue((json["api"] as? [String: Any])?["type"], forKey: "type")
                    plugin?.api?.setValue((json["api"] as? [String: Any])?["url"], forKey: "url")
                    plugin?.api?.setValue((json["api"] as? [String: Any])?["has_user_authentication"], forKey: "has_user_authentication")
                    plugin?.auth?.setValue((json["auth"] as? [String: Any])?["type"], forKey: "type")
//                    print(plugin)
                    if let plag = plugin {
                        temp.append(plag)
                    }
                }
                CoreDataManager.shared.saveData()
                DispatchQueue.main.async {
                    self.pluginList = temp
                }
            }
            
        }
    }
    
    
}

extension PluginViewModel {
    
    private func fetchPlugin(name_for_human: String) -> PluginManifest? {
        let request: NSFetchRequest<PluginManifest> = PluginManifest.fetchRequest()
        request.predicate = NSPredicate(format: "name_for_human == %@", name_for_human)
        let results: [PluginManifest] = CoreDataManager.shared.fetch(request: request)
        return results.first
    }
    private func fetchManifest(name_for_human: String?) -> PluginManifest? {
        guard let name = name_for_human, !name.isEmpty else { return nil }
        let request: NSFetchRequest<PluginManifest> = PluginManifest.fetchRequest()
        request.predicate = NSPredicate(format: "name_for_human == %@", name)
        let results: [PluginManifest] = CoreDataManager.shared.fetch(request: request)
        return results.first
        
    }
}
