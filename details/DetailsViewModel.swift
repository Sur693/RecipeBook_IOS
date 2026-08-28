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
        repository.toggle(recipeId)
    }
    
    private func loadRecipe() {
        Task {
            do {
                let response = try await FoodService.shared.getRecipeById(id: recipeId)
                
                guard let meal = response.meals?.first else {
                    return
                }
                
                let previews = DataConverter.mealDataModelToDetail(model: meal)
                let videoId = getYoutubeId(from: previews.videoRes)
                
                await MainActor.run {
                    self.state = RecipeDetailUiState.recipe(value: previews, youtubeVideoId: videoId)
                }
            } catch {
                await MainActor.run {
                    self.state = RecipeDetailUiState.loading
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

