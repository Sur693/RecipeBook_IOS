//
//  RecipePreview.swift
//  RecipeBook
//
//  Created by Admin on 25.08.2026.
//
struct RecipePreview: Codable, Identifiable { // codable для перевода в другие форматы, identifiable для использования в списках (list, foreach)
    let id: String
    let imageRes: String
    let category: String
    let title: String
    let area: String
    let quantity: Int
}

