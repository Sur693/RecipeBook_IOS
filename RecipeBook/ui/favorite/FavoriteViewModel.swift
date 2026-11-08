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
        defer { loading = false}
        
        recipes = repository.fetchPreviews()
    }

    // Обновляет список после добавления или удаления рецепта.
        func refreshRecipes() {
            loadRecipes()
    }
}
