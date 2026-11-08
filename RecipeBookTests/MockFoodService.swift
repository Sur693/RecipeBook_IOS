//
//  MockFoodService.swift
//  RecipeBookTests
//
//  Created by Admin on 07.11.2026.
//

import Foundation
@testable import RecipeBook

final class MockFoodService: FoodServiceProtocol {

    // Ответы.
    var randomResponse = MealsResponse(meals: [])
    var searchResponse = MealsResponse(meals: [])
    var categoryResponse = MealsResponse(meals: [])
    var areaResponse = MealsResponse(meals: [])
    var ingredientResponse = MealsResponse(meals: [])
    var recipeResponse = MealsResponse(meals: [])

    // Запоминаем, с какими параметрами вызывали сервис.
    private(set) var searchedName: String?
    private(set) var searchedCategory: String?
    private(set) var searchedArea: String?
    private(set) var searchedIngredient: String?
    private(set) var requestedRecipeId: String?
    
    // Ошибки.
    var nameError: Error? = nil
    var categoryError: Error? = nil
    var areaError: Error? = nil
    var ingredientError: Error? = nil
    var recipeByIdError: Error? = nil

    func getRandomMeal() async throws -> MealsResponse {
        randomResponse
    }

    func getRecipeById(id: String) async throws -> MealsResponse {
        requestedRecipeId = id
        try recipeByIdError.map { throw $0 }
        return recipeResponse
    }

    func searchMealsByName(name: String) async throws -> MealsResponse {
        searchedName = name
        try nameError.map { throw $0 }
        return searchResponse
    }

    func filterByCategory(category: String) async throws -> MealsResponse {
        searchedCategory = category
        try categoryError.map { throw $0 }
        return categoryResponse
    }

    func filterByArea(area: String) async throws -> MealsResponse {
        searchedArea = area
        try areaError.map { throw $0 }
        return areaResponse
    }

    func filterByIngredient(ingredient: String) async throws -> MealsResponse {
        searchedIngredient = ingredient
        try ingredientError.map { throw $0 }
        return ingredientResponse
    }
}
