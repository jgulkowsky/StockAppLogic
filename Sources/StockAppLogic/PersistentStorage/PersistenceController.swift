//
//  PersistenceController.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 11/01/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private init(inMemory: Bool = false) {
        guard
            let objectModelURL = Bundle.module.url(forResource: "Model", withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: objectModelURL)
        else {
            fatalError("Failed to retrieve the object model")
        }
        
        container = NSPersistentContainer(name: "Model", managedObjectModel: objectModel)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

