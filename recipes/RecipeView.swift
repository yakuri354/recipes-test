//
//  RecipeView.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI
import MarkdownUI

struct RecipeView: View {
    var recipe: Recipe
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.system(size: 32))
                    .fontWeight(.heavy)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                Markdown(recipe.content)
                Spacer()
            }
            .padding()
        }
    }
}

func mockRecipes() -> [Recipe] {
    return [
        Recipe(id: 0, name: "Mock recipe 1", content: "asjdfklsfj"),
        Recipe(id: 0, name: "Mock recipe 2", content: "22222lsdjflksdf"),
        Recipe(id: 0, name: "Mock recipe 3", content: "32090238402"),
        Recipe(id: 0, name: "Mock recipe 4", content: "432098420"),
        Recipe(id: 0, name: "Mock recipe 5", content: "5092384")
    ]
}

#Preview {
    RecipeView(recipe: Recipe(id: 0, name: "test name", content: "test content\n# ksjdflksjd\n[aboba](https://google.com/)"))
        .frame(minWidth: 500, minHeight: 300, alignment: .topLeading)
}
