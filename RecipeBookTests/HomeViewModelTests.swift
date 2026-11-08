//
//  HomeViewModelTests.swift
//  RecipeBookTests
//
//  Created by Admin on 07.11.2026.
//

import XCTest
@testable import RecipeBook

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // Ожидаем завершения начальной загрузки случайных рецептов
    private func waitForLoading(_ viewModel: HomeViewModel) async {
        for _ in 0..<100 {
            if !viewModel.isLoading {
                return
            }

            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTFail("Initial loading did not finish")
    }

    
    func test_searchRecipes_success_updatesRecipeList() async throws {
        let mockService = MockFoodService()

        let json = """
        {
            "meals": [
                {
                    "idMeal": "52772",
                    "strMeal": "Teriyaki Chicken",
                    "strCategory": "Chicken",
                    "strArea": "Japanese",
                    "strMealThumb": "https://example.com/meal.jpg",
                    "strIngredient1": "Chicken",
                    "strIngredient2": "Soy sauce"
                }
            ]
        }
        """.data(using: .utf8)!

        mockService.searchResponse = try JSONDecoder().decode(
            MealsResponse.self,
            from: json
        )

        let viewModel = HomeViewModel(foodService: mockService)

        // Ждем завершения начальной загрузки.
        await waitForLoading(viewModel)

        // Запускаем поиск рецептов.
        viewModel.searchRecipes(query: "Chicken")

        // Ждем завершения поиска.
        await waitForLoading(viewModel)

        XCTAssertEqual(viewModel.recipes.count, 1)
        XCTAssertEqual(viewModel.recipes.first?.id, "52772")
        XCTAssertEqual(viewModel.recipes.first?.title, "Teriyaki Chicken")
        XCTAssertEqual(viewModel.recipes.first?.category, "Chicken")
        XCTAssertEqual(viewModel.recipes.first?.area, "Japanese")
        XCTAssertEqual(viewModel.recipes.first?.imageRes, "https://example.com/meal.jpg")
        XCTAssertEqual(viewModel.recipes.first?.quantity, 2)
        
        XCTAssertEqual(viewModel.searchQuery, "Chicken")
        XCTAssertEqual(mockService.searchedName, "Chicken")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchRecipes_emptyResponse_clearsRecipeList() async {
        // Подготавливаем сервис с пустым ответом.
        let mockService = MockFoodService()
        mockService.searchResponse = MealsResponse(meals: [])
        
        let viewModel = HomeViewModel(foodService: mockService)
        
        // Ждем завершения начальной загрузки.
        await waitForLoading(viewModel)

        // Запускаем поиск рецептов.
        viewModel.searchRecipes(query: "UnknownRecipe")

        // Ждем завершения поиска.
        await waitForLoading(viewModel)
        
        // Cписок рецептов должен быть пустым.
        XCTAssertTrue(viewModel.recipes.isEmpty)
        // Поисковый запрос должен сохраниться.
        XCTAssertEqual(mockService.searchedName, "UnknownRecipe")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchRecipes_error_clearsRecipeListAndStopsLoading() async {
        let mockService = MockFoodService()
        mockService.searchResponse = MealsResponse(meals: [])
        mockService.nameError = NSError(
                domain: "Network error",
                code: -1
            )
        
        let viewModel = HomeViewModel(foodService: mockService)
        
        // Ждем завершения начальной загрузки.
        await waitForLoading(viewModel)

        // Выполняем поиск, который должен завершиться ошибкой.
        viewModel.searchRecipes(query: "Chicken")

        // Ждем завершения поиска.
        await waitForLoading(viewModel)
        
        // После ошибки список пуст.
        XCTAssertTrue(viewModel.recipes.isEmpty)
        // Поисковый запрос должен сохраниться.
        XCTAssertEqual(mockService.searchedName, "Chicken")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchByFilter_category_success_updatesRecipeList() async throws {
        let mockService = MockFoodService()
        
        let json = """
        {
            "meals": [
                {
                    "idMeal": "52772",
                    "strMeal": "Teriyaki Chicken",
                    "strCategory": "Chicken",
                    "strArea": "Japanese",
                    "strMealThumb": "https://example.com/meal.jpg",
                    "strIngredient1": "Chicken",
                    "strIngredient2": "Soy sauce"
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(
                MealsResponse.self,
                from: json
        )
        
        // Ответ на запрос рецептов по категории.
        mockService.categoryResponse = response

        // Ответ на запрос полной информации о рецепте по id.
        mockService.recipeResponse = response

        let viewModel = HomeViewModel(foodService: mockService)

        // Ждем завершения начальной загрузки.
        await waitForLoading(viewModel)

        viewModel.searchByFilter(
            filterValue: "Chicken",
            filterType: .category
        )

        await waitForLoading(viewModel)

        XCTAssertEqual(mockService.searchedCategory, "Chicken")
        XCTAssertEqual(mockService.requestedRecipeId, "52772")

        XCTAssertEqual(viewModel.recipes.count, 1)
        XCTAssertEqual(viewModel.recipes.first?.title, "Teriyaki Chicken")
        XCTAssertEqual(viewModel.recipes.first?.id, "52772")

        XCTAssertEqual(viewModel.activeFilter?.0, .category)
        XCTAssertEqual(viewModel.activeFilter?.1, "Chicken")

        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchByFilter_category_error_clearsRecipeListAndStopsLoading() async {
        let mockService = MockFoodService()
        mockService.categoryError = NSError(
            domain: "Network error",
            code: -1
        )

        let viewModel = HomeViewModel(foodService: mockService)

        await waitForLoading(viewModel)

        viewModel.searchByFilter(
            filterValue: "Chicken",
            filterType: .category
        )

        await waitForLoading(viewModel)

        // После ошибки список пуст.
        XCTAssertTrue(viewModel.recipes.isEmpty)
        // Фильтр должен не установиться.
        XCTAssertNil(viewModel.activeFilter)
        // Cостояние загрузки должно сброситься даже при ошибке.
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchByFilter_ingredient_success_updatesRecipeList() async throws {
        let mockService = MockFoodService()
        
        let json = """
        {
            "meals": [
                {
                    "idMeal": "52772",
                    "strMeal": "Teriyaki Chicken",
                    "strCategory": "Chicken",
                    "strArea": "Japanese",
                    "strMealThumb": "https://example.com/meal.jpg",
                    "strIngredient1": "Chicken",
                    "strIngredient2": "Soy sauce"
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(
                MealsResponse.self,
                from: json
        )
        
        mockService.ingredientResponse = response
        mockService.recipeResponse = response

        let viewModel = HomeViewModel(foodService: mockService)

        await waitForLoading(viewModel)

        viewModel.searchByFilter(
            filterValue: "Chicken",
            filterType: .ingredient
        )

        await waitForLoading(viewModel)

        XCTAssertEqual(mockService.searchedIngredient, "Chicken")
        XCTAssertEqual(mockService.requestedRecipeId, "52772")

        XCTAssertEqual(viewModel.recipes.count, 1)
        XCTAssertEqual(viewModel.recipes.first?.title, "Teriyaki Chicken")
        XCTAssertEqual(viewModel.recipes.first?.id, "52772")

        XCTAssertEqual(viewModel.activeFilter?.0, .ingredient)
        XCTAssertEqual(viewModel.activeFilter?.1, "Chicken")

        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchByFilter_ingredient_error_clearsRecipeListAndStopsLoading() async {
        let mockService = MockFoodService()
        mockService.ingredientError = NSError(
                domain: "Network error",
                code: -1
            )
        
        let viewModel = HomeViewModel(foodService: mockService)
        
        // Ждем завершения начальной загрузки.
        await waitForLoading(viewModel)

        // Выполняем поиск, который должен завершиться ошибкой.
        viewModel.searchByFilter(filterValue: "Chicken", filterType: .ingredient)

        // Ждем завершения поиска.
        await waitForLoading(viewModel)
        
        // После ошибки список пуст.
        XCTAssertTrue(viewModel.recipes.isEmpty)
        // Фильтр должен не установиться.
        XCTAssertNil(viewModel.activeFilter)
        // Cостояние загрузки должно сброситься даже при ошибке.
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchByFilter_ingredient_errorLoadingRecipe_clearsRecipeListAndStopsLoading() async throws {
        let mockService = MockFoodService()
        mockService.recipeByIdError = NSError(
            domain: "Network error",
            code: -1
        )

        let json = """
        {
            "meals": [
                {
                    "idMeal": "52772",
                    "strMeal": "Teriyaki Chicken",
                    "strMealThumb": "https://example.com/meal.jpg",
                    "strCategory": "Chicken",
                    "strArea": "Japanese",
                    "strIngredient1": "Chicken"
                },
                {
                    "idMeal": "52773",
                    "strMeal": "Teriyaki",
                    "strMealThumb": "https://example.com/meal.jpg",
                    "strCategory": "Chicken",
                    "strArea": "Japanese",
                    "strIngredient1": "Chicken"
                }
            ]
        }
        """.data(using: .utf8)!

        mockService.ingredientResponse = try JSONDecoder().decode(
            MealsResponse.self,
            from: json
        )

        let viewModel = HomeViewModel(foodService: mockService)

        await waitForLoading(viewModel)

        viewModel.searchByFilter(
            filterValue: "Chicken",
            filterType: .ingredient
        )

        await waitForLoading(viewModel)

        XCTAssertEqual(mockService.searchedIngredient, "Chicken")
        XCTAssertEqual(mockService.requestedRecipeId, "52773")

        XCTAssertTrue(viewModel.recipes.isEmpty)

        XCTAssertEqual(viewModel.activeFilter?.0, .ingredient)
        XCTAssertEqual(viewModel.activeFilter?.1, "Chicken")

        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_searchByFilter_switchingFromSearch_clearsQueryAndSetsActiveFilter() async {
        let mockService = MockFoodService()
        mockService.searchResponse = MealsResponse(meals: [])
        
        let viewModel = HomeViewModel(foodService: mockService)
        
        // Ждем завершения начальной загрузки.
        await waitForLoading(viewModel)

        // Выполняем поиск, который должен завершиться ошибкой.
        viewModel.searchRecipes(query: "Chicken")

        // Ждем завершения поиска.
        await waitForLoading(viewModel)
        
        XCTAssertEqual(mockService.searchedName, "Chicken")

        viewModel.searchByFilter(
            filterValue: "Chicken",
            filterType: .ingredient
        )
        await waitForLoading(viewModel)
        
        XCTAssertEqual(viewModel.searchQuery, "")

        XCTAssertEqual(viewModel.activeFilter?.0, .ingredient)
        XCTAssertEqual(viewModel.activeFilter?.1, "Chicken")

        XCTAssertFalse(viewModel.isLoading)
    }
}
