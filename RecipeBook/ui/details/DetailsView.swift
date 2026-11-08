//
//  DetailsView.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//

import SwiftUI
import UIKit
import Kingfisher

struct DetailsView: View {
    
    @ObservedObject var viewModel: DetailsViewModel // следим за изменениями vm
    @ObservedObject var repository: FavoriteRepository
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .recipe(let recipe, let youtubeVideoId):
            VStack(spacing: 0) { 
                
                ZStack(alignment: .topTrailing) {
                    KFImage(URL(string: recipe.imageRes))
                        .placeholder {
                            Color(.systemGray5)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 175)
                        .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(recipe.title)
                        .font(.system(size: 24, weight: .bold))

                        .padding(.top, 20)
                    
                    Text("\(recipe.category) · \(recipe.area)")
                        .font(.system(size: 18))
                        .padding(EdgeInsets(top: 14, leading: 0, bottom: 20, trailing: 14))
                    
                    ScrollView {
                        VStack (alignment: .leading, spacing: 8){
                            HStack  {
                                Text("Ingredients:")
                                    .font(.system(size: 20, weight: .semibold))
                                Text(" \(recipe.ingredients.count)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.gray)
                                
                            }
                            ForEach(Array(zip(recipe.ingredients, recipe.measures).enumerated()), id: \.offset) { _, pair in
                                HStack {
                                    Text(pair.0)   // ингредиент
                                    Spacer()
                                    Text(pair.1)   // мера
                                }
                            }
                            
                            Spacer().frame(height: 16)
                            
                            Text("Instructions:")
                                .font(.system(size: 20, weight: .semibold))
                            if let videoId = youtubeVideoId {
                                YoutubeButton(videoId: videoId)
                            }
                            Text(recipe.instructions)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            .padding(.top, -40)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: { viewModel.toggleFavorite() }
                    ){
                        Image(systemName: repository.favorites.contains(recipe.id) ? "heart.fill" : "heart")
                            .foregroundStyle(.black)
                    }
                }
            }
        case .error:
            VStack(spacing: 12) {
                Text("Failed to load recipe")
                Button("Try Again") {
                    viewModel.loadRecipe()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct YoutubeButton: View {
    let videoId: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoId)"){
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Watch on Youtube")
                    .font(.system(size: 18, weight: .bold))
                
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.vertical, 10)
        }
    }
}
