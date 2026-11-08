//
//  DetailsViewModel.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//

import Foundation
internal import Combine

enum RecipeDetailUiState {
    case loading
    case recipe (value: RecipeDetail, youtubeVideoId: String?)
    case error
}

class DetailsViewModel: ObservableObject {
    
    @Published var state: RecipeDetailUiState = .loading
    
    private let recipeId: String
    let repository: FavoriteRepository
    
    var favorites: Set<String> {
        repository.favorites
    }
    
    init (
        recipeId: String,
        repository: FavoriteRepository
    ){
        self.recipeId = recipeId
        self.repository = repository
        loadRecipe()
    }
    
    func toggleFavorite() {
        if case .recipe(let value, _) = state {
            repository.toggle(value)
        }
    }
    
    func loadRecipe() {
        // Сначала ищем рецепт в локальной базе.
        if let saved = repository.fetchDetail(id: recipeId) {
            let videoId = getYoutubeId(from: saved.videoRes)
            state = .recipe(value: saved,youtubeVideoId: videoId)
            return
        }

        // Если рецепта нет в базе, загружаем его с сервера.
        Task {
            do {
                let response = try await FoodService.shared.getRecipeById(id: recipeId)
                
                guard let meal = response.meals?.first else {
                    await MainActor.run {
                        self.state = .error
                    }
                    return
                }
                
                let previews = DataConverter.mealDataModelToDetail(model: meal)
                let videoId = getYoutubeId(from: previews.videoRes)
                
                await MainActor.run {
                    self.state = RecipeDetailUiState.recipe(value: previews, youtubeVideoId: videoId)
                }
            } catch {
                await MainActor.run {
                    self.state = .error
                }
            }
        }
    }
    
    private func getYoutubeId(from url: String?) -> String? {
        guard let url = url, !url.isEmpty else { return nil }
        
        if let match = url.firstMatch(of: /watch\?v=([^&#]+)/) {
            return String(match.1) // найденное внутри круглых скобок
        }
        
        if let match = url.firstMatch(of: /youtu\.be\/([^?#]+)/) {
            return String(match.1) // найденное внутри круглых скобок
        }
        
        return nil
    }
}

