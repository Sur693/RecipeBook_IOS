//
//  DataConverterTests.swift
//  RecipeBookTests
//
//  Created by Admin on 27.10.2026.
//

import XCTest
@testable import RecipeBook

final class DataConverterTests: XCTestCase {

    // Превращает JSON-строку в MealDataModel.
    private func makeMeal(json: String) throws -> MealDataModel {
        try JSONDecoder().decode(MealDataModel.self, from: Data(json.utf8))
    }

    func test_mealDataModelToDetail_mapsRecipeFields() throws {
        // Arrange
        let meal = try makeMeal(json: """
        {
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "Mix the ingredients and cook.",
            "strMealThumb": "https://example.com/meal.jpg",
            "strYoutube": "https://youtube.com/watch?v=example",
            "strIngredient1": "Chicken",
            "strIngredient2": "Soy sauce",
            "strMeasure1": "500 g",
            "strMeasure2": "2 tbsp"
        }
        """)

        // Act
        let detail = DataConverter.mealDataModelToDetail(model: meal)

        // Assert
        XCTAssertEqual(detail.id, "52772")
        XCTAssertEqual(detail.title, "Teriyaki Chicken")
        XCTAssertEqual(detail.category, "Chicken")
        XCTAssertEqual(detail.area, "Japanese")
        XCTAssertEqual(detail.imageRes, "https://example.com/meal.jpg")
        XCTAssertEqual(detail.videoRes, "https://youtube.com/watch?v=example")
        XCTAssertEqual(detail.instructions, "Mix the ingredients and cook.")
        XCTAssertEqual(detail.ingredients, ["Chicken", "Soy sauce"])
        XCTAssertEqual(detail.measures, ["500 g", "2 tbsp"])
        XCTAssertEqual(detail.quantity, 2)
    }
    
    func test_mealDataModelToDetail_nullOptionalFields_becomeEmptyStrings() throws {
        let meal = try makeMeal(json: """
        {
           "idMeal": "123"
        }
        """)

        let detail = DataConverter.mealDataModelToDetail(model: meal)

        XCTAssertEqual(detail.id, "123")
        XCTAssertEqual(detail.title, "")
        XCTAssertEqual(detail.category, "")
        XCTAssertEqual(detail.area, "")
        XCTAssertEqual(detail.imageRes, "")
        XCTAssertEqual(detail.videoRes, "")
        XCTAssertEqual(detail.instructions, "")
        XCTAssertEqual(detail.ingredients, [])
        XCTAssertEqual(detail.measures, [])
        XCTAssertEqual(detail.quantity, 0)
    }

    func test_mealDataModelToPreview_mapsRecipeFields() throws {
        let meal = try makeMeal(json: """
        {
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "Mix the ingredients and cook.",
            "strMealThumb": "https://example.com/meal.jpg",
            "strYoutube": "https://youtube.com/watch?v=example",
            "strIngredient1": "Chicken",
            "strIngredient2": "Soy sauce",
            "strMeasure1": "500 g",
            "strMeasure2": "2 tbsp"
        }
        """)

        let preview = DataConverter.mealDataModelToPreview(model: meal)

        XCTAssertEqual(preview.id, "52772")
        XCTAssertEqual(preview.title, "Teriyaki Chicken")
        XCTAssertEqual(preview.category, "Chicken")
        XCTAssertEqual(preview.area, "Japanese")
        XCTAssertEqual(preview.imageRes, "https://example.com/meal.jpg")
        XCTAssertEqual(preview.quantity, 2)
    }

    func test_mealDataModelToPreview_nullOptionalFields_becomeEmptyStrings() throws {
        let meal = try makeMeal(json: """
        {
            "idMeal": "123"
        }
        """)

        let preview = DataConverter.mealDataModelToPreview(model: meal)

        XCTAssertEqual(preview.id, "123")
        XCTAssertEqual(preview.title, "")
        XCTAssertEqual(preview.category, "")
        XCTAssertEqual(preview.area, "")
        XCTAssertEqual(preview.imageRes, "")
        XCTAssertEqual(preview.quantity, 0)
    }
    
    func test_mealDataModelToDetail_countsIngredientsAndMeasures() throws {
        let meal = try makeMeal(json: """
        {
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "Mix the ingredients and cook.",
            "strMealThumb": "https://example.com/meal.jpg",
            "strYoutube": "https://youtube.com/watch?v=example",
            "strIngredient1": "Chicken",
            "strIngredient2": "Soy sauce",
            "strIngredient3": " ",
            "strMeasure1": "2 tbsp",
            "strMeasure2": " ",
            "strMeasure3": ""
        }
        """)

        let detail = DataConverter.mealDataModelToDetail(model: meal)

        XCTAssertEqual(detail.id, "52772")
        XCTAssertEqual(detail.title, "Teriyaki Chicken")
        XCTAssertEqual(detail.ingredients.count, 2)
        XCTAssertEqual(detail.measures.count, 2)
    }
    
}
