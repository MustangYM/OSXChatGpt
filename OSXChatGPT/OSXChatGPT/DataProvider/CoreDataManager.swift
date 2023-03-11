//
//  CoreDataManager.swift
//  OSXChatGPT
//
//  Created by CoderChan on 2023/3/8.
//

import SwiftUI
import CoreData

class CoreDataManager {
    static var shared = CoreDataManager()
    let container: NSPersistentContainer!

    private init() {
        container = NSPersistentContainer(name: "OSXChatGPT")
        let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("OSXChatGPT.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreURLKey)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func fetch<R: NSFetchRequestResult>(_ entityName: String, sorting: [NSSortDescriptor]?) -> [R] {
        let request = NSFetchRequest<R>(entityName: entityName)
        request.sortDescriptors = sorting
        do {
            return try container.viewContext.fetch(request)
        } catch let error {
            print("\(error)")
        }
        return []
    }
    func fetch<R: NSFetchRequestResult>(request: NSFetchRequest<R>) -> [R] {
        do {
            return try container.viewContext.fetch(request)
        } catch let error {
            print("\(error)")
        }
        return []
    }
    func delete(object: NSManagedObject) {
        withAnimation {
            container.viewContext.delete(object)
            saveData()
        }
        
    }

    func delete(objects: [NSManagedObject]) {
        withAnimation {
            objects.forEach { container.viewContext.delete($0) }
            saveData()
            container.viewContext.refreshAllObjects()
        }
    }

    func saveData() {
        print("saveData")
        do {
            try container.viewContext.save()
        } catch {
            print("Error saving (error)")
        }
    }
}
