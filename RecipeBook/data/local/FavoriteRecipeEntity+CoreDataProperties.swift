//
//  FavoriteRecipeEntity+CoreDataProperties.swift
//  RecipeBook
//
//  Created by Admin on 24.10.2026.
//
//

public import Foundation
public import CoreData


public typealias FavoriteRecipeEntityCoreDataPropertiesSet = NSSet

extension FavoriteRecipeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteRecipeEntity> {
        return NSFetchRequest<FavoriteRecipeEntity>(entityName: "FavoriteRecipeEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageRes: String?
    @NSManaged public var category: String?
    @NSManaged public var title: String?
    @NSManaged public var area: String?
    @NSManaged public var ingredientsData: Data?
    @NSManaged public var measuresData: Data?
    @NSManaged public var videoRes: String?
    @NSManaged public var instructions: String?
    @NSManaged public var quantity: Int64

}

extension FavoriteRecipeEntity : Identifiable {

}
