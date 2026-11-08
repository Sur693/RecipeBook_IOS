//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Admin on 25.08.2026.
//

import SwiftUI

@main
struct RecipeBookApp: App {

    // Получаем общий экземпляр PersistenceController, который управляет хранилищем Core Data.
    // shared позволяет использовать один и тот же контроллер в разных частях приложения.
    //private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Передаём контекст Core Data в окружение SwiftUI.
            //.environment(
               // \.managedObjectContext,
                // viewContext — основной контекст Core Data, через который интерфейс работает с базой данных.
                //persistenceController.container.viewContext
            //)
        }
    }
}
