
//
//  RecipeItemView.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//
import SwiftUI

struct RecipeItemView: View {
    
    let recipe: RecipePreview
    let onRecipeTap: (String) -> Void
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                if  !recipe.area.isEmpty {
                    Text(recipe.area)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        Spacer()
                    }
                }
                    .padding(16)
            
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                
                    Text(recipe.title)
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    
                    HStack {
                        Text(recipe.category)
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        HStack (spacing: 8) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                            Text("\(recipe.quantity)")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                    }
                }
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.4))
        }
        .frame(height: 250)
        .background(
            AsyncImage(url: URL(string: recipe.imageRes)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            onRecipeTap(recipe.id)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        
    }
}

#Preview {
    RecipeItemView(
        recipe: RecipePreview(
            id: "52771",
            imageRes: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
            category: "Vegetarian",
            title: "Spicy Arrabiata Penne",
            area: "Italian",
            quantity: 8
        ),
        onRecipeTap: { _  in print("Нажали на тестовый рецепт пасты") }
    )
    .padding()
}
