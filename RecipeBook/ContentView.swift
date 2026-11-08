//
//  ContentView.swift
//  RecipeBook
//
//  Created by Admin on 25.08.2026.
//

import SwiftUI

enum Route: Hashable {
    case detail(recipeId: String)
    case favorite
    case filter
}

// Обертка для хранения DetailsViewModel.
struct DetailsScreen: View {
    @StateObject private var viewModel: DetailsViewModel
    @ObservedObject var repository: FavoriteRepository

    // Инициализация с id рецепта и репозиторием.
    init(recipeId: String, repository: FavoriteRepository) {
        self.repository = repository
        _viewModel = StateObject(
            wrappedValue: DetailsViewModel(
                recipeId: recipeId,
                repository: repository
            )
        )
    }

    // Передаем данные в экран деталей.
    var body: some View {
        DetailsView(
            viewModel: viewModel,
            repository: repository
        )
    }
}


struct ContentView: View {
    @StateObject var viewModel = HomeViewModel() // создаем единственный экзмепляр vm
    @StateObject var favoriteRepository = FavoriteRepository()
    @State private var path = NavigationPath() // история переходов
    
    var body: some View {
        NavigationStack (path: $path) { // контейнер, следящий за path
            HomeView(
                viewModel: viewModel,
                onFilterTap: { path.append(Route.filter) },
                onFavoriteTap: { path.append(Route.favorite) },
                onRecipeTap: { recipeId in path.append(Route.detail(recipeId: recipeId)) }
            )
                .navigationDestination(for: Route.self) { route in 
                    switch route {
                    case .detail(let recipeId):
                        DetailsScreen(
                                recipeId: recipeId,
                                repository: favoriteRepository
                            )
                    case .favorite:
                        FavoriteView(
                            viewModel: FavoriteViewModel(repository: favoriteRepository),
                            onRecipeTap: { recipeId in path.append(Route.detail(recipeId: recipeId)) }
                        )
                    case .filter:
                        FilterView(
                            onApply: { filterType, value in
                                viewModel.searchByFilter(filterValue: value, filterType: filterType)
                                path.removeLast() // удаляем FilterView из истории навигации
                            }
                        )
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
