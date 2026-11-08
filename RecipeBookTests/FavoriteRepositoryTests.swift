//
//  FavoriteRepositoryTests.swift
//  RecipeBookTests
//
//  Created by Admin on 27.10.2026.
//

import XCTest
@testable import RecipeBook

final class FavoriteRepositoryTests: XCTestCase {
    
    private var persistence: PersistenceController?
    private var repository: FavoriteRepository?
    
    // setUp запускается перед каждым тестом: у каждого теста своя чистая база.
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)

        guard let persistence else {
            XCTFail("PersistenceController was not initialized")
            return
        }
        
        repository = FavoriteRepository(context: persistence.viewContext)
    }
    
    
    override func tearDown() {
        repository = nil
        persistence = nil
        super.tearDown()
    }
    
    
    // Готовый рецепт для тестов.
    private func makeRecipe(id: String = "52772") -> RecipeDetail {
        RecipeDetail(
            id: id,
            imageRes: "https://example.com/meal.jpg",
            category: "Chicken",
            title: "Teriyaki Chicken",
            area: "Japanese",
            ingredients: ["Chicken", "Soy sauce"],
            measures: ["500 g", "2 tbsp"],
            videoRes: "https://youtube.com/watch?v=example",
            instructions: "Mix the ingredients and cook.",
            quantity: 2
        )
    }
    
    
    func test_toggle_fetchDetail_addsRecipeToCoreData() {
        
        guard let repository else {
            XCTFail("Repository was not initialized")
            return
        }
        
        let recipe = makeRecipe()
        repository.toggle(recipe)
        
        let result = repository.fetchDetail(id: recipe.id)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, recipe.id)
        XCTAssertEqual(result?.title, recipe.title)
        XCTAssertEqual(result?.category, recipe.category)
        XCTAssertEqual(result?.area, recipe.area)
        XCTAssertEqual(result?.instructions, recipe.instructions)
        XCTAssertEqual(result?.ingredients, recipe.ingredients)
        XCTAssertEqual(result?.measures, recipe.measures)
        XCTAssertEqual(result?.quantity, recipe.quantity)
    }
    
    
    func test_toggle_removesRecipeFromCoreData() {
        
        guard let repository else {
            XCTFail("Repository was not initialized")
            return
        }
        
        let recipe = makeRecipe()
        repository.toggle(recipe)
        repository.toggle(recipe)
        
        XCTAssertNil(repository.fetchDetail(id: recipe.id))
        XCTAssertTrue(repository.favorites.isEmpty)
    }
    
    
    func test_fetchDetail_returnsNilWhenRecipeDoesNotExist() {
        
        guard let repository else {
            XCTFail("Repository was not initialized")
            return
        }
        
        let result = repository.fetchDetail(id: "unknown-id")
        
        XCTAssertNil(result)
    }
    
    
    func test_favorites_containsAddedRecipeID() {
        
        guard let repository else {
            XCTFail("Repository was not initialized")
            return
        }
        
        let recipe = makeRecipe()
        repository.toggle(recipe)
        
        XCTAssertEqual(repository.favorites, Set([recipe.id]))
        XCTAssertEqual(repository.favorites.count, 1)
    }
    
    
    func test_init_loadsExistingFavoritesFromCoreData() {
        
        guard let repository else {
            XCTFail("Repository was not initialized")
            return
        }
        guard let persistence else {
            XCTFail("PersistenceController was not initialized")
            return
        }
        
        let recipe = makeRecipe()
        repository.toggle(recipe)

        let newRepository = FavoriteRepository(
            context: persistence.viewContext
        )

        XCTAssertTrue(newRepository.favorites.contains(recipe.id))
    }
    
    
    func test_fetchPreviews_returnsSavedRecipes() {
        
        guard let repository else {
            XCTFail("Repository was not initialized")
            return
        }

        let firstRecipe = makeRecipe(id: "52772")
        let secondRecipe = makeRecipe(id: "52773")

        repository.toggle(firstRecipe)
        repository.toggle(secondRecipe)

        let result = repository.fetchPreviews()
        XCTAssertEqual(result.count, 2)

        let ids = Set(result.map { $0.id })
        XCTAssertEqual(ids, Set(["52772", "52773"]))
    }
}
