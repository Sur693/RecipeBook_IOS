//
//  FavoritesView.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//

import SwiftUI

struct FavoriteView: View {
    
    @ObservedObject var viewModel: FavoriteViewModel // следим за изменениями vm
    
    let onRecipeTap: (String) -> Void
    
    var body: some View {
        
        VStack {
            
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(2.0)
            } else {
                if viewModel.recipes.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.recipes) { recipe in
                                RecipeItemView(
                                    recipe: recipe,
                                    onRecipeTap: { onRecipeTap($0) }
                                )
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) { 
                Text("Favorites")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
