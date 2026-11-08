//
//  FavoritesRepository.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//

internal import Combine
import CoreData

class FavoriteRepository: ObservableObject { // Для перерисовывания при изменениях.
    
    @Published var favorites: Set<String> = []
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
        let array = fetchAll().compactMap { $0.id }
        favorites = Set(array)

    }
    
    // Прочитать все сохранённые рецепты
    private func fetchAll() -> [FavoriteRecipeEntity] {
        let request = FavoriteRecipeEntity.fetchRequest() // Все записи этой сущности.
        return (try? context.fetch(request)) ?? [] // Безопасное чтение.
    }
    
    // Одна запись по id.
    private func fetchEntity(id: String) -> FavoriteRecipeEntity? {
        let request = FavoriteRecipeEntity.fetchRequest()
        // Условие поиска, как WHERE id = ...; %@ подставляет значение id.
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1 // нужна максимум одна запись
        return try? context.fetch(request).first
    }

    // Карточки для экрана избранного.
    func fetchPreviews() -> [RecipePreview] {
        fetchAll().map { $0.toPreview() }
    }

    // Полный рецепт из базы: нужен, чтобы открыть детали без интернета.
    // Возвращает nil, если рецепта в избранном нет.
    func fetchDetail(id: String) -> RecipeDetail? {
        fetchEntity(id: id)?.toDetail()
    }

    // Записать изменения на диск
    private func saveContext() {
        guard context.hasChanges else { return } // Если менять нечего, выходим.
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить: \(error)")
        }
    }

    func toggle(_ recipe: RecipeDetail) {
        if favorites.contains(recipe.id) {
            // Убираем из избранного: находим запись и помечаем на удаление.
            if let entity = fetchEntity(id: recipe.id) {
                context.delete(entity)
            }
            favorites.remove(recipe.id)
        } else {
            // Добавляем: создаем запись в «черновике» и заполняем данными рецепта.
            let entity = FavoriteRecipeEntity(context: context)
            entity.fill(from: recipe)
            favorites.insert(recipe.id)
        }
        saveContext() // Сохраняем изменения.
    }
}

