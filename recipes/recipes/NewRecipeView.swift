//
//  NewRecipeView.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI

struct NewRecipeView: View {
    @Binding var recipe: Recipe
    
    @Environment var recipes: RecipeStorage
    @Binding var displaySheet: Bool
    @Binding var then: (Recipe, RecipeStorage) throws -> Void
    
    var body: some View {
        Form {
            TextField("Name", text: $recipe.name)
            
            LabeledContent("Content") {
                TextEditor(text: $recipe.content)
                    .alignmentGuide(.firstTextBaseline) { $0[.firstTextBaseline] + 9 }
                    .font(.monospaced(Font.body)())
            }
            
            Button(action: {
                displaySheet = false
                do {
                    try then(recipe, recipes)
                } catch {
                    // todo
                    
                }
            }) {
                Text("Done")
            }
        }
    }
}

//#Preview {
//    NewRecipeView(displaySheet: .constant(true), recipes: nil).padding()
//}
