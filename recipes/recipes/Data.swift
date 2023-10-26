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

class RecipeRef: ObservableObject {
    @Published private(set) var recipe: Recipe
    
    weak var storage: RecipeStorage?
    
    init(recipe: Recipe, storage: RecipeStorage?) {
        self.recipe = recipe
        self.storage = storage
    }
    
    deinit {
        if let s = storage {
            s.unalloc(id: recipe.id)
        }
    }
}

class SearchViewRange: ObservableObject {
    @Published private(set) var range: Range<Int>
    @Binding var query: String
    
    private var storage: RecipeStorage
    
    init(storage: RecipeStorage, query: Binding<String>) {
        self._query = query
        self.storage = storage
        range = 0..<0
        update()
    }
    
    func update() {
        let cnt = (try? storage.db.scalar("select count(*) from recipes where name like %\(query)%") as? Int64) ?? 0
        
        range = 0..<Int(cnt)
    }
}

class Weak<T: AnyObject> {
    weak var v: T?
    
    init(v: T? = nil) {
        self.v = v
    }
}

class RecipeStorage {
    private(set) var loadedRecipes: [Int64: Weak<RecipeRef>] = [:]
    var db: Connection
    
    init() throws {
        let path = try RecipeStorage.dbPath()
        
        db = try Connection(path)
        
        try initDB()
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
    
    public func get(pos: Int64) -> RecipeRef? {
        guard let id = try? db.scalar("select id from recipes order by id limit 1") as? Int64 else {
            return nil
        }
        return get(id: id)
    }
    
    public func get(id: Int64) -> RecipeRef? {
        if let cached = loadedRecipes[id] {
            if let recipe = cached.v {
                return recipe
            } else {
                loadedRecipes.removeValue(forKey: id)
            }
        }
        
        guard let row = try? db.prepare("select * from recipes where id = ?", [id]).next() else {
            return nil
        }
        
        let recipe = Recipe(id: row[0] as! Int64, name: row[1] as! String, content: row[2] as! String)
        let ref = RecipeRef(recipe: recipe, storage: self)
        
        loadedRecipes[id] = Weak(v: ref)
        
        return ref
    }
    
    public func insert(recipe: Recipe) throws {
        try db.prepare("insert into recipes (name, content) values (cast(? as text), cast(? as text))", [recipe.name, recipe.content]).run()
    }
    
    public func update(recipe: Recipe) throws {
        try db.prepare("update recipes set name = cast(? as text), content = cast(? as text) where id = ?", [recipe.name, recipe.content, recipe.id]).run()
    }
    
    public func delete(recipe: Recipe) throws {
        try db.prepare("delete from recipes where id = ?", recipe.id).run()
    }
    
    public func getImage(name: String) throws -> NSImage? {
        if let data = try db.prepare("select data from images where name = ?", name).next()?[0] {
            NSImage(data: Data.fromDatatypeValue(data as! Blob))
        } else {
            nil
        }
    }
    
    public func unalloc(id: Int64) {
        loadedRecipes.removeValue(forKey: id)
    }
    
    public func putImage(name: String, image: NSImage) throws {
        // TODO
        // db.prepare("insert into images (name, data) values (cast(? as text), cast(? as blob))", [name, image.jpeg])
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
