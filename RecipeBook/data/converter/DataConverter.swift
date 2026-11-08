//
//  DataConverter.swift
//  RecipeBook
//
//  Created by Admin on 25.08.2026.

struct DataConverter {
    
    static func mealDataModelToDetail(model: MealDataModel) -> RecipeDetail {
        return RecipeDetail(
            id: model.idMeal,
            imageRes: model.strMealThumb ?? "",
            category: model.strCategory ?? "",
            title: model.strMeal ?? "",
            area: model.strArea ?? "",
            ingredients: model.ingredients,
            measures: model.measures,
            videoRes: model.strYoutube ?? "",
            instructions: model.strInstructions ?? "",
            quantity: model.ingredients.count
        )
    }
    
    static func mealDataModelToPreview(model: MealDataModel) -> RecipePreview {
        return RecipePreview(
            id: model.idMeal,
            imageRes: model.strMealThumb ?? "",
            category: model.strCategory ?? "",
            title: model.strMeal ?? "",
            area: model.strArea ?? "",
            quantity: model.ingredients.count
        )
    }
}
