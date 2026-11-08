//
//  FilterView.swift
//  RecipeBook
//
//  Created by Admin on 27.08.2026.
//

import SwiftUI

struct FilterView: View {
    @State private var selectedFilterType: FilterType? = nil
    @State private var searchText: String = ""
    @State private var selectedItem: String? = nil
    
    let onApply: (FilterType, String) -> Void
    
    var body: some View {
        VStack{
            if selectedFilterType == nil {
                filterTypeSelectionView
            } else {
                filterListView
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    private var filterTypeSelectionView: some View {
        VStack (alignment: .leading, spacing: 8) {
            
            FilterOption( title: "Areas", action: { selectedFilterType = .area })
            FilterOption( title: "Categories", action: { selectedFilterType = .category })
            FilterOption( title: "Ingredients", action: { selectedFilterType = .ingredient })
            
            Spacer()
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) { 
                Text("Search by")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    private var filterListView: some View {
        VStack{
            TextField("Search", text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            ScrollView {
                VStack (spacing: 12){
                    ForEach (filteredItems, id: \.self) { item in
                        HStack{
                            Image(systemName: item == selectedItem ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.gray)
                            Text(item)
                                .font(.system(size: 20))
                        }
                        .onTapGesture {
                            selectedItem = item
                            if let selectedFilter = selectedFilterType {
                                onApply(selectedFilter, item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    }
                    Spacer()
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(textForFilter)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var textForFilter: String {
        switch selectedFilterType {
        case .area: return "Areas"
        case .category: return "Categories"
        case .ingredient: return "Ingredients"
        default: return ""
        }
    }
    
    private var allItems: [String] {
        switch selectedFilterType {
        case .area: return FilterData.areas
        case .category: return FilterData.categories
        case .ingredient: return FilterData.ingredients
        default: return []
        }
    }
    
    private var filteredItems: [String] {
        if searchText.isEmpty {
            return allItems
        }
        else {
            return allItems.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
}


struct FilterOption: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                Text(title)
                    .font(.system(size: 22))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
