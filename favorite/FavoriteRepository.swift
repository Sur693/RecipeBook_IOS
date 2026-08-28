//
//  FavoritesRepository.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//

import Foundation
internal import Combine

class FavoriteRepository: ObservableObject { // для перерисовывания при изменениях
    
    @Published var favorites: Set<String> = []
    
    private let key = "favorites_ids"
    
    init(){
        let array = UserDefaults.standard.stringArray(forKey: key) ?? [] //обращение к общему стандартному хранилищу за списком избранного
        favorites = Set(array)
    }
    
    private func save(){
        UserDefaults.standard.set(Array(favorites), forKey: key)
    }
    
    func toggle(_ id: String){
        if favorites.contains(id){
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        save()
    }
}

