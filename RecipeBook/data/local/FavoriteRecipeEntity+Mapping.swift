//
//  FavoriteRecipeEntity+Mapping.swift
//  RecipeBook
//
//  Created by Admin on 24.10.2026.
///Users/admin/Desktop/RecipeBook/RecipeBook/data/repository/FavoriteRepository.swift

import Foundation
import CoreData

extension FavoriteRecipeEntity {

    // Переносит данные рецепта в объект Core Data.
    func fill(from recipe: RecipeDetail) {
        id = recipe.id
        title = recipe.title
        imageRes = recipe.imageRes
        category = recipe.category
        area = recipe.area
        videoRes = recipe.videoRes
        instructions = recipe.instructions
        quantity = Int64(recipe.quantity)

        // Преобразуем массивы строк в Data для хранения в Core Data.
        ingredientsData = try? JSONEncoder().encode(recipe.ingredients)
        measuresData = try? JSONEncoder().encode(recipe.measures)
    }

    func toDetail() -> RecipeDetail {
        RecipeDetail(
            id: id ?? "",
            imageRes: imageRes ?? "",
            category: category ?? "",
            title: title ?? "",
            area: area ?? "",
            ingredients: ingredientsData.flatMap(\.toStringArray) ?? [],
            measures: measuresData.flatMap(\.toStringArray) ?? [],
            videoRes: videoRes ?? "",
            instructions: instructions ?? "",
            quantity: Int(quantity)
        )
    }
    
    func toPreview() -> RecipePreview {
            RecipePreview(
                id: id ?? "",            // поля в базе опциональные, подставляем пустую строку
                imageRes: imageRes ?? "",
                category: category ?? "",
                title: title ?? "",            // title в сущности не опциональный
                area: area ?? "",
                quantity: Int(quantity)
            )
        }
}

// Преобразует Data обратно в массив строк.
private extension Data {
    var toStringArray: [String]? {
        try? JSONDecoder().decode([String].self, from: self)
    }
}
