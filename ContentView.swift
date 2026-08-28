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
                        DetailsView(
                            viewModel: DetailsViewModel(recipeId: recipeId, repository: favoriteRepository),
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
