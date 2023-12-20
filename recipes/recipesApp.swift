//
//  recipesApp.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext)
    var modelCtx: ModelContext
    
    @State var dataLoaded = false;
    
    func loadData() throws {
        let data = try modelCtx.fetch(FetchDescriptor<Cuisine>())
        
        if data.count > 0 {
            dataLoaded = true;
            return;
        }
        
        mockData__(modelCtx: modelCtx)
        //modelCtx.insert(Cuisine(name: "american cuisine"))
        dataLoaded = true;
    }
    
    var body: some View {
//        if let v = try? ContentView() {
//            v
//        } else {
//            Text("Failed to open app database")
//                .foregroundStyle(.secondary)
//                .font(.largeTitle)
//                .padding()
//        }
        
        if dataLoaded {
            ContentView()
        } else {
            Text("Loading data...")
                .foregroundStyle(.secondary)
                .font(.largeTitle)
                .padding()
                .onAppear {
                    try? self.loadData()
                }
        }
    }
}

@main
struct recipesApp: App {
    let container: ModelContainer
    
    init() {
        let conf = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let schema = Schema([Cuisine.self, Recipe.self, RecipeStep.self, RecipeIngredient.self, Ingredient.self])
        
        do {
            container = try ModelContainer.init(for: schema, configurations: conf)
        } catch {
            fatalError("Failed to init ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(container)
        }
    }
}
