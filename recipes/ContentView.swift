//
//  ContentView.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI
import Fuse
import SwiftData

struct ContentView: View {
    @Query var cuisines: [Cuisine]
    @State var searchText: String = ""
    @State var selectedCuisine: Cuisine? = nil
    @State var selectedRecipe: Recipe? = nil
    
//    private func sort(s: String) -> [Recipe] {
//        if searchText == "" {
//            return recipes.recipes
//        } else {
//            return recipes.recipes.map({x in (x, fuse.search(s, in: x.name))})
//                .filter({x in x.1 != nil})
//                .sorted(by: {a, b in a.1!.score < b.1!.score})
//                .map({x in x.0})
//        }
//    }
    
    var body: some View {
        NavigationSplitView {
            List(cuisines, id: \.self, selection: $selectedCuisine) { c in
                Text(c.name)
            }
        } content: {
            if let sel_c = selectedCuisine {
                List(sel_c.recipes.filter({r in searchText == "" || r.name.localizedStandardContains(searchText)}), id: \.self, selection: $selectedRecipe) { r in
                    Text(r.name)
                        .font(.title3)
                    // Text(r.desc)
                }
            } else {
                Text("Select a cuisine")
                    .padding()
            }
        } detail: {
            if let sel_r = selectedRecipe {
                Text(sel_r.name)
                    .font(.largeTitle)
                Text(sel_r.desc)
            } else {
                Text("Select a recipe")
                    .padding()
            }
        }
        .searchable(text: $searchText)
        .onAppear {
            if cuisines.count > 0 { selectedCuisine = cuisines[0] }
        }
//        }.toolbar {
//            ToolbarItem {
//                Button(action: {
//                    sheetRecipe = Recipe(id: 0, name: "", content: "")
//                    sheetAction = { r, rs in
//                        try rs.insert(recipe: r)
//                    }
//                    sheetPresented = true
//                }) {
//                    Image(systemName: "plus")
//                }
//            }
            
//            ToolbarItem {
//                if getSelected() != nil {
//                    Button(action: {
//                        sheetRecipe = getSelected()!
//                        sheetAction = { r, rs in
//                            try rs.update(recipe: r)
//                        }
//                        sheetPresented = true
//                    }) {
//                        Image(systemName: "square.and.pencil")
//                    }
//                }
//            }
            
//            ToolbarItem {
//                if getSelected() != nil {
//                    Button(action: {
//                        try! recipes.delete(recipe: getSelected()!)
//                    }) {
//                        Image(systemName: "trash")
//                    }
//                }
//            }
//        }.sheet(
//            isPresented: $sheetPresented, content: {
//                NewRecipeView(recipe: $sheetRecipe, displaySheet: $sheetPresented, then: $sheetAction)
//                    .padding()
//                    .frame(minWidth: 500, minHeight: 300)
//            }
//        ).environment(recipes)
//        .searchable(text: $searchText)
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Cuisine.self, configurations: config)
//    let cuisine = mockData();
//    container.mainContext.insert(cuisine)
//    
//    return try! ContentView()
//        .modelContainer(container)
//}


