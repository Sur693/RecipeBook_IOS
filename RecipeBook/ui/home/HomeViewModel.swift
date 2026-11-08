//
//  HomeViewModel.swift
//  RecipeBook
//
//  Created by Admin on 26.08.2026.
//
import Foundation
internal import Combine

class HomeViewModel: ObservableObject {
    
    @Published var recipes: [RecipePreview] = []
    @Published var searchQuery: String = ""
    @Published var activeFilter: (FilterType, String)? = nil
    @Published var isLoading: Bool = false
    
    private let foodService: FoodServiceProtocol

    init(foodService: FoodServiceProtocol = FoodService.shared) {
        self.foodService = foodService
        loadRandomRecipes()
    }
    
    func loadRandomRecipes() {
        isLoading = true
        Task { // асинхроная задача
            do {
                let response = try await getRecipes()
                let allMeals = response.compactMap { $0.meals }.flatMap { $0 } // убираем nil и вложенные массивы
                let previews = allMeals.map { DataConverter.mealDataModelToPreview(model: $0) }
                
                await MainActor.run { // переключаемся на главный поток
                    self.recipes = previews
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.recipes = []
                    self.isLoading = false
                }
            }
        }
    }
    
    private func getRecipes() async throws -> [MealsResponse] {
        try await withThrowingTaskGroup(of: MealsResponse.self) { group in // withThrowingTaskGroup - паралленые запросы
            for _ in
                    0..<10 {
                group.addTask {
                    try await self.foodService.getRandomMeal()
                }
            }
            var results: [MealsResponse] = []
            
            for try await response in group { // ждет завершения задачи чтобы добавить ее в массив
                results.append(response)
            }
            return results
        }
    }
    
    func searchRecipes(query: String) {
        isLoading = true
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        activeFilter = nil
        Task {
            do {
                let response = try await foodService.searchMealsByName(name: query)
                let meals = response.meals ?? []
                
                let previews = meals.map { DataConverter.mealDataModelToPreview(model: $0) }
                
                await MainActor.run { // переключаемся на главный поток
                    self.recipes = previews
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.recipes = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func searchByFilter(filterValue: String, filterType: FilterType) {
        isLoading = true
        searchQuery = ""
         Task {
             do {
                 let response = switch (filterType) {
                    case FilterType.area: try await foodService.filterByArea(area: filterValue)
                    case FilterType.category: try await foodService.filterByCategory(category: filterValue)
                 case FilterType.ingredient: try await foodService.filterByIngredient(ingredient: filterValue)
                 }
                 
                 let meals = response.meals ?? []

                 var fetchedMeals: [MealDataModel] = []
                 
                 for meal in meals {
                     if let response = try? await foodService.getRecipeById(id: meal.idMeal),
                        let fullMeal = response.meals?.first { // достаем первое (единственное) блюдо из ответа массива
                         fetchedMeals.append(fullMeal)
                     }
                 }
                 
                 let previews = fetchedMeals.map { DataConverter.mealDataModelToPreview(model: $0) }
                 
                 await MainActor.run { // переключаемся на главный поток
                     self.recipes = previews
                     self.isLoading = false
                     self.activeFilter = (filterType, filterValue)
                 }
             } catch {
                 await MainActor.run {
                     self.recipes = []
                     self.isLoading = false
                 }
             }
        }
    }
    
    
    func clearFilter() {
        self.activeFilter = nil
        loadRandomRecipes()
    }
    
    func refresh() async {
        isLoading = true
        do {
            try await Task.sleep(nanoseconds: 300_000_000)
            let response = try await getRecipes()
            let allMeals = response.compactMap { $0.meals }.flatMap { $0 } // убираем nil и вложенные массивы
            let previews = allMeals.map { DataConverter.mealDataModelToPreview(model: $0) }
            
            await MainActor.run { // переключаемся на главный поток
                self.recipes = previews
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.recipes = []
                self.isLoading = false
            }
        }
    }
}
