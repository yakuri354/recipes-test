//
//  ContentView.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI
import Fuse
import SwiftData
import SQLite

struct ContentView: View {
    var db: Connection
    @State var cuisines: [Cuisine]
    @State var recipes: DbView<Recipe, SQLite.Table>
    @State var searchText: String = ""
    @State var selectedCuisine: Cuisine? = nil
    @State var selectedRecipeN: Int? = nil
    
    private func searchQuery(s: String, cuisine: Int64) -> SQLite.Table {
        return Recipe.table().filter(Expression<Int64>("cuisine_id") == cuisine).where(Expression<String>("name").like("%" + s + "%"))
    }
    
    init() throws {
        // let dbPath = Bundle.main.url(forResource: "db", withExtension: "sqlite")!.path()
        let dbPath = FileManager.default.homeDirectoryForCurrentUser.path() + "/test.sqlite"
        
        debugPrint(dbPath)
        
        db = try Connection(dbPath)
        cuisines = try! db.prepare(Cuisine.table()).map {r in try! r.decode()}
        recipes = try DbView(db: db, query: Recipe.table())
        recipes = try DbView(db: db, query: self.searchQuery(s: "", cuisine: 0))
    }
    
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
            if selectedCuisine != nil {
                List(0..<recipes.size, id: \.self, selection: $selectedRecipeN) { i in
                    let _ = debugPrint("getting " + String(i) + " from " + String(selectedCuisine?.id ?? -1))
                    if let r = try? recipes.getNth(n: i) {
                        Text(r.name)
                            .font(.title3)
                    } else {
                        Text("Recipe not found")
                    }
                    
                    // Text(r.desc)
                }
            } else {
                Text("Select a cuisine")
                    .padding()
            }
        } detail: {
            if let sel_r = selectedRecipeN {
                var _ = debugPrint("updating recipe with cuisine " + String(self.selectedCuisine?.id ?? -1))
                if let r = try! recipes.getNth(n: sel_r) {
                    Text(r.name)
                        .font(.largeTitle)
                    Text(r.description)
                } else {
                    Text("Recipe not found")
                }
            } else {
                Text("Select a recipe")
                    .padding()
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { old, new in
            debugPrint("update searchText " + new + " cuisine " + String(self.selectedCuisine?.id ?? -1))
            try! recipes.search(q: self.searchQuery(s: new, cuisine: self.selectedCuisine?.id ?? 0))
        }
        .onChange(of: selectedCuisine) { old, new in
            debugPrint("update selectedCuisine " + String(new?.id ?? -1))
            try! recipes.search(q: self.searchQuery(s: self.searchText, cuisine: new?.id ?? 0))
        }
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


