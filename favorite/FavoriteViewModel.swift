//
//  FavoritesViewModel.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//

import Foundation
internal import Combine

class FavoriteViewModel: ObservableObject {
    
    @Published var recipes: [RecipePreview] = []
    @Published var loading: Bool = false
    
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repository = repository
        loadRecipes()
        
    }
    
    private func loadRecipes() {
        loading = true
        Task {
            do {
                let favoriteIds = repository.favorites
                let favoriteMeals = try await getRecipes(ids: favoriteIds)
                    
                await MainActor.run {
                    recipes = favoriteMeals
                    loading = false
                }
            } catch {
                await MainActor.run {
                    recipes = []
                    loading = false
                }
            }
        }
    }

    private func getRecipes(ids: Set<String>) async throws -> [RecipePreview] {
        var recipes : [RecipePreview] = []
        for recipeId in ids {
            let response = try await FoodService.shared.getRecipeById(id: recipeId)
            if let meal = response.meals?.first {
                let preview = DataConverter.mealDataModelToPreview(model: meal)
                recipes.append(preview)
            }
        }
        return recipes
    }
}
