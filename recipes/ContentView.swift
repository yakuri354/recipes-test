//
//  ContentView.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI
import Fuse

struct ContentView: View {
    @StateObject private var recipes: RecipeStorage
    
    @State private var sheetPresented: Bool = false
    @State var sheetAction: (Recipe, RecipeStorage) throws -> Void = {_, _ in }
    @State var sheetRecipe: Recipe = Recipe(id: 0, name: "", content: "")
    @State var searchText: String = ""
    
    private let fuse: Fuse = Fuse()
    
    init() throws {
        let storage = try RecipeStorage()
        _recipes = StateObject(wrappedValue: storage)
    }
    
    @State private var selectedRecipe: Int64?
    
    private func sort(s: String) -> [Recipe] {
        if searchText == "" {
            return recipes.recipes
        } else {
            return recipes.recipes.map({x in (x, fuse.search(s, in: x.name))})
                .filter({x in x.1 != nil})
                .sorted(by: {a, b in a.1!.score < b.1!.score})
                .map({x in x.0})
        }
    }
    
    private func getSelected() -> Recipe? {
        if let recipeId = selectedRecipe {
            recipes.recipes.first(where: {r in r.id == recipeId})
        } else {
            nil
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(sort(s: searchText), selection: $selectedRecipe) { r in
                Text(r.name)
            }
        } detail: {
            if let rec = getSelected() {
                RecipeView(recipe: rec)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Select a recipe").padding()
            }
        }.toolbar {
            ToolbarItem {
                Button(action: {
                    sheetRecipe = Recipe(id: 0, name: "", content: "")
                    sheetAction = { r, rs in
                        try rs.insert(recipe: r)
                    }
                    sheetPresented = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem {
                if getSelected() != nil {
                    Button(action: {
                        sheetRecipe = getSelected()!
                        sheetAction = { r, rs in
                            try rs.update(recipe: r)
                        }
                        sheetPresented = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            
            ToolbarItem {
                if getSelected() != nil {
                    Button(action: {
                        try! recipes.delete(recipe: getSelected()!)
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }.sheet(
            isPresented: $sheetPresented, content: {
                NewRecipeView(recipe: $sheetRecipe, displaySheet: $sheetPresented, then: $sheetAction)
                    .padding()
                    .frame(minWidth: 500, minHeight: 300)
            }
        ).environment(recipes)
        .searchable(text: $searchText)
    }
}

#Preview {
    try! ContentView()
}
