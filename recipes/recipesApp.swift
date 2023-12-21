//
//  recipesApp.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
//        if let v = try? ContentView() {
//            v
//        } else {
//            Text("Failed to open app database")
//                .foregroundStyle(.secondary)
//                .font(.largeTitle)
//                .padding()
//        }
        

        try! ContentView()
        //            ContentView()
//        } catch {
//            debugPrint(error)
//            Text("Error")
//                .foregroundStyle(.secondary)
//                .font(.largeTitle)
//                .padding()
//        }
    }
}

@main
struct recipesApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
