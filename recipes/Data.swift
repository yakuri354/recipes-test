//
//  Data.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import Foundation
import SwiftUI
import SQLite
import MarkdownUI

typealias View = SwiftUI.View // :(
typealias Binding = SwiftUI.Binding // :(

struct Recipe: Identifiable {
    let id: Int64
    
    var name: String
    var content: String
}

protocol RecipeRepo: ObservableObject, Observable {
    var recipes: [Recipe] { get }
    
    func fetch() throws
    func insert(recipe: Recipe) throws
}

class FakeRecipes: RecipeRepo {
    @Published private(set) var recipes: [Recipe] = []
    
    func fetch() {}
    func insert(recipe: Recipe) {}
}

struct AssetImageProvider: ImageProvider {
    @Binding
    public var recipes: RecipeStorage
    
    func makeImage(url: URL?) -> some View {
        if let name = url?.lastPathComponent,
           let data = try? recipes.getImage(name: name) {
            Image(nsImage: data)
        } else {
            Text("Failed to load image: \(url?.absoluteString ?? "<nil>")")
                .bold()
                .backgroundStyle(.red)
        }
    }
}

class RecipeStorage: RecipeRepo {
    @Published private(set) var recipes: [Recipe] = []
    var db: Connection
    
    init() throws {
        let path = try RecipeStorage.dbPath()
        
        db = try Connection(path)
        
        try initDB()
        
        try fetch()
    }
    
    private func initDB() throws {
        try db.execute("""
            create table if not exists recipes (
                id integer primary key autoincrement,
                name text,
                content text
            );
        
            create table if not exists images (
                id integer primary key autoincrement,
                name text unique not null,
                data blob
            );
        """)
    }
    
    public func insert(recipe: Recipe) throws {
        try db.prepare("insert into recipes (name, content) values (cast(? as text), cast(? as text))", [recipe.name, recipe.content]).run()
        try fetch()
    }
    
    public func update(recipe: Recipe) throws {
        try db.prepare("update recipes set name = cast(? as text), content = cast(? as text) where id = ?", [recipe.name, recipe.content, recipe.id]).run()
        try fetch()
    }
    
    public func delete(recipe: Recipe) throws {
        try db.prepare("delete from recipes where id = ?", recipe.id).run()
        try fetch()
    }
    
    public func getImage(name: String) throws -> NSImage? {
        if let data = try db.prepare("select data from images where name = ?", name).next()?[0] {
            NSImage(data: Data.fromDatatypeValue(data as! Blob))
        } else {
            nil
        }
    }
    
    public func putImage(name: String, image: NSImage) throws {
        // TODO
        // db.prepare("insert into images (name, data) values (cast(? as text), cast(? as blob))", [name, image.jpeg])
    }
    
    public func fetch() throws {
        recipes = try db.prepare("select * from recipes").map { row in
            Recipe(id: row[0] as! Int64, name: row[1] as! String, content: row[2] as! String)
        }
    }
    
    
    private static func dbPath() throws -> String {
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/" + Bundle.main.bundleIdentifier!

        // create parent directory inside application support if it doesn’t exist
        try FileManager.default.createDirectory(
            atPath: path, withIntermediateDirectories: true, attributes: nil
        )
        
        return path + "/db.sqlite"
    }
}
