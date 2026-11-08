//
//  HomeView.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//
import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel // следим за изменениями vm
    
    let onFilterTap: () -> Void
    let onFavoriteTap: () -> Void
    let onRecipeTap: (String) -> Void
    
    var body: some View {
        
        VStack {
            HStack {
                TextField("Search recipes", text: Binding(
                    get: { viewModel.searchQuery },
                    set: { viewModel.searchRecipes(query: $0) }
                    ))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                Button(action: onFilterTap) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 28))
                        .foregroundStyle(.black)
                }
                Button(action: onFavoriteTap) {
                    Image(systemName: "heart")
                        .font(.system(size: 28))
                        .foregroundStyle(.black)
                }
                    
            }
            .padding(.horizontal, 16)
            
            if let filter = viewModel.activeFilter {
                HStack {
                    Text("Filter: \(filter.1)")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                    Spacer()
                    Button(action: { viewModel.clearFilter() }
                    ){
                        Text("Clear")
                            .font(.system(size: 16))
                            .foregroundStyle(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
                
            Text("Recipes you can make")
                .font(.system(size: 20, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.vertical)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(2.0)
            } else if viewModel.recipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("No recipes found")
                        .font(.system(size: 20, weight: .bold))

                    Text("Check your internet connection and try again.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        viewModel.loadRandomRecipes()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
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
                }
                .refreshable { // потянуть вниз чтобы обновить
                    await viewModel.refresh()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Fridge")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

