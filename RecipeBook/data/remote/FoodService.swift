//
//  FoodService.swift
//  RecipeBook
//
//  Created by Admin on 25.08.2026.
//

import Foundation

protocol FoodServiceProtocol {
    func getRandomMeal() async throws -> MealsResponse
    func getRecipeById(id: String) async throws -> MealsResponse
    func searchMealsByName(name: String) async throws -> MealsResponse
    func filterByCategory(category: String) async throws -> MealsResponse
    func filterByArea(area: String) async throws -> MealsResponse
    func filterByIngredient(ingredient: String) async throws -> MealsResponse
}

class FoodService: FoodServiceProtocol {
    
    static let shared = FoodService() // companion object внутри класса, singleton
    private let baseURL = "https://www.themealdb.com/api/json/v1/1/"
    
    func fetch<T: Decodable>(url: URL) async throws -> T { // generic-функция, которая работает с любым типом T, который соответствует протоколу Decodable
        let (data, _) = try await URLSession.shared.data(from: url) // выполнение сетевого запроса и возвращение кортежа (data: Data, response: URLResponse)
        return try JSONDecoder().decode(T.self, from: data) // превращаем данные в тип T
    }
    
    func getRandomMeal() async throws -> MealsResponse {
        guard let url = URL(string: "\(baseURL)random.php") else {
            throw URLError(.badURL)
        }
        return try await fetch(url: url) // await - дождаться выполнения
    }
    
    func getRecipeById(id: String) async throws -> MealsResponse {
        guard let url = URL(string: "\(baseURL)lookup.php?i=\(id)") else {
            throw URLError(.badURL)
        }
        return try await fetch(url: url)
    }
    
    func searchMealsByName(name: String) async throws -> MealsResponse {
        guard let url = URL(string: "\(baseURL)search.php?s=\(name)") else {
            throw URLError(.badURL)
        }
        return try await fetch(url: url)
    }
    
    func filterByCategory(category: String) async throws -> MealsResponse {
        guard let url = URL(string: "\(baseURL)filter.php?c=\(category)") else {
            throw URLError(.badURL)
        }
        return try await fetch(url: url)
    }
    
    func filterByArea(area: String) async throws -> MealsResponse {
        guard let url = URL(string: "\(baseURL)filter.php?a=\(area)") else {
            throw URLError(.badURL)
        }
        return try await fetch(url: url)
    }
    
    func filterByIngredient(ingredient: String) async throws -> MealsResponse {
        guard let url = URL(string: "\(baseURL)filter.php?i=\(ingredient)") else {
            throw URLError(.badURL)
        }
        return try await fetch(url: url)
    }
}
