//
//  File.swift
//  RecipeBook
//
//  Created by Admin on 24.10.2026.
//

import Foundation
import CoreData

public final class PersistenceController {
    // Один общий экземпляр на всё приложение.
    static let shared = PersistenceController()

    let container: NSPersistentContainer // Область памяти.

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(name: "Model")

        // Для тестов и Preview.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Открываем файл базы.
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data не загрузилась: \(error)")
            }
        }
    }

    // Контекст
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}
