//
//  Data.swift
//  recipes
//
//  Created by yakuri354 on 05.10.2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import SQLite

typealias View = SwiftUI.View // :(
typealias Binding = SwiftUI.Binding // :(

// create table if not exists recipes (
//    id integer primary key autoincrement,
//    name text,
//
//    desc text,
//    final_hint text,
//    servings integer,
//    cook_time_m double,
//    likes integer,
//    dislikes integer,
//    agg_rating double,
//    cover_img integer,
//
//    foreign key (cover_img) references images(id)
// );


//@Model
//final class DataImage {
//    // todo
//    var name: String?
//    var url: String?
//    
//    init(name: String? = nil, url: String? = nil) {
//        self.name = name
//        self.url = url
//    }
//}
//

protocol Model: Identifiable, Hashable, Codable {
    static var tableName: String { get }
}

extension Model {
    static func table() -> SQLite.Table {
        return Table(tableName)
    }
}

class DbView<T: Model, Q: QueryType & SchemaType> {
    private let cacheAheadN = 100
    
    private var query: Q
    public private(set) var size: Int
    private var db: Connection
    private var cache: [Int: T] = [:]
    
    func loadAt(n: Int) throws {
        let q = query.order(Expression<Int64>("id")).limit(cacheAheadN, offset: n)
        
        var i = 0
        for r in try db.prepare(q) {
            let val: T = try! r.decode()
            cache[n + i] = val
            i += 1
        }
    }
    
    func getNth(n: Int) throws -> T? {
        if n > size {
            return nil
        }
        
        if let x = cache[n] {
            return x
        }
        
        try loadAt(n: n);
        
        return cache[n]
    }
    
    func search(q: Q) throws {
        query = q
        cache = [:]
        
        self.size = try db.scalar(q.count)
    }
    
    init(db: Connection, query: Q) throws {
        self.db = db
        self.query = query
        self.size = 0
        
        try self.search(q: query)
    }
}

struct Recipe: Model {
    static var tableName: String = "recipes"
    
    var id: Int64
    
    var name: String = ""
    var description: String = ""
    
    var servings: Int = 1
    var cook_time_m: Double = 0.0
    var likes: Int = 0
    var dislikes: Int = 0
    var agg_rating: Double = 0.0
    
    var cuisine_id: Int64
    
    // var image
}


struct RecipeStep: Model {
    static var tableName: String = "recipe_step"
    
    var id: Int64
    
    var title: String
    var content: String
    var pos: Int64
    
    // var image
    
    var recipeId: Int64
}

struct RecipeIngredient: Codable {
    var ingredientId: Int64
    var recipeId: Int64
    
    var amount: Double
}

struct Ingredient: Codable {
    var name: String
    var unit: String
}

struct Cuisine: Model {
    static var tableName = "cuisines"
    
    var id: Int64
    var name: String
}
//
//func mockData__() {
//    let ru_c = Cuisine(id: 0, name: "Американская кухня");
//    
//    let brownie = Recipe(
//        id: 1,
//        name: "Брауни", description: """
//Один из самых популярных десертов в мире — брауни — был придуман в 1893 году на кухне легендарного отеля Palmer House в Чикаго. Этот пирог там пекут до сих пор по оригинальному рецепту, покрывая сверху абрикосовой глазурью. В домашней версии, впрочем, у брауни получается такая изумительная сахарная корочка, что глазировать ее было бы преступлением.
//У традиционных шоколадных брауни ванильный аромат, хрустящая корочка и влажная серединка. В торт также добавляют грецкие орехи или фисташки, а еще клюкву.
//""",
////        cuisine: ru_c,
//        servings: 2,
//        cook_time_m: 40,
//        likes: 3027,
//        dislikes: 308,
//        agg_rating: 4.7,
//        cuisine: 0
//    )
//    
//    let steps = [
//        RecipeStep(
//            title: "Шаг 1",
//            content: "sdkfjsдлывадлыволыоывалдыовдлоыв",
//            recipeId: 1
//        ),
//        RecipeStep(
//            title: "Шаг 2",
//            content: "sdkfjsдлывадлыволыоывалдыовдлоыв",
//            recipeId: 1
//        ),
//        RecipeStep(
//            title: "Шаг 3",
//            content: "sdkfjsдлывадлыволыоывалдыовдлоыв",
//            recipeId: 1
//        ),
//        RecipeStep(
//            title: "Шаг 4",
//            content: "sdkfjsдлывадлыволыоывалдыовдлоыв",
//            recipeId: 1
//        )
//    ]
//    
//    let ingredients = [
//        Ingredient(name: "мука", unit: "у.е."),
//        Ingredient(name: "мусор", unit: "шт."),
//        Ingredient(name: "дерево", unit: "г.")
//    ]
//    
////    let recipeIngredients = [
////        RecipeIngredient(amount: 10, ),
////        RecipeIngredient(amount: 100),
////        RecipeIngredient(amount: 10000)
////    ]
//}

//
//
////struct AssetImageProvider: ImageProvider {
////    @Binding
////    public var recipes: CuisineRef
////    
////    func makeImage(url: URL?) -> some View {
////        if let name = url?.lastPathComponent,
////           let data = try? recipes.getImage(name: name) {
////            Image(nsImage: data)
////        } else {
////            Text("Failed to load image: \(url?.absoluteString ?? "<nil>")")
////                .bold()
////                .backgroundStyle(.red)
////        }
////    }
////}
////
////class CuisineRef: ObservableObject, Observable {
////    @Published private(set) var recipes: [Recipe] = []
////    var cuisineId: Int64
////    var db: Database
////    
////    init(db: Database, cuisineId: Int64) {
////        self.db = db
////        self.cuisineId = cuisineId
////    }
////    
////    public func insert(recipe: Recipe) throws {
////        try db.c.prepare("insert into recipes (name, content) values (cast(? as text), cast(? as text))", [recipe.name, recipe.content]).run()
////        try fetch()
////    }
////    
////    public func update(recipe: Recipe) throws {
////        try db.c.prepare("update recipes set name = cast(? as text), content = cast(? as text) where id = ?", [recipe.name, recipe.content, recipe.id]).run()
////        try fetch()
////    }
////    
////    public func delete(recipe: Recipe) throws {
////        try db.c.prepare("delete from recipes where id = ?", recipe.id).run()
////        try fetch()
////    }
////    
////    public func getImage(name: String) throws -> NSImage? {
////        if let data = try db.c.prepare("select data from images where name = ?", name).next()?[0] {
////            NSImage(data: Data.fromDatatypeValue(data as! Blob))
////        } else {
////            nil
////        }
////    }
////    
////    public func fetch() throws {
////        recipes = try db.c.prepare("select * from recipes").map { row in
////            Recipe(id: row[0] as! Int64, name: row[1] as! String, content: row[2] as! String)
////        }
////    }
////}
////
////
////class Database {
////    var c: Connection
////    
////    init() throws {
////        let path = try Database.dbPath()
////        
////        c = try Connection(path)
////        
////        try initDB()
////    }
////    
////    private func initDB() throws {
////        try c.execute("""
//            create table if not exists recipes (
//                id integer primary key autoincrement,
//                name text,
//                
//                description text,
//                final_hint text,
//                servings integer,
//                cook_time_m double,
//                likes integer,
//                dislikes integer,
//                agg_rating double,
//                cover_img integer,
//                
//                foreign key (cover_img) references images(id)
//            );
////        
//            create table if not exists ingredients (
//                id integer primary key autoincrement,
//                name text,
//                unit text
//            );
//        
//            create table if not exists step (
//                id integer primary key autoincrement,
//                title text,
//                content text,
//                image integer,
//        
//                foreign key (image) references images(id)
//            );
//        
//            create table if not exists cuisine (
//                id integer primary key autoincrement,
//                name text
//            );
//        
//            create table if not exists recipe_step (
//                r_id integer not null,
//                s_id integer not null,
//                pos integer not null,
//        
//                foreign key (r_id) references recipes(id),
//                foreign key (s_id) references steps(id)
//            );
//        
//            create table if not exists recipe_ingredient (
//                r_id integer not null,
//                ing_id integer not null,
//                amount double not null,
//        
//                foreign key (r_id) references recipes(id),
//                foreign key (ing_id) references ingredients(id)
//            );
////        
////            create table if not exists images (
////                id integer primary key autoincrement,
////                name text unique not null,
////                data blob
////            );
////        """)
////    }
////    
////    private static func dbPath() throws -> String {
////        let path = NSSearchPathForDirectoriesInDomains(
////            .applicationSupportDirectory, .userDomainMask, true
////        ).first! + "/" + Bundle.main.bundleIdentifier!
////
////        // create parent directory inside application support if it doesn’t exist
////        try FileManager.default.createDirectory(
////            atPath: path, withIntermediateDirectories: true, attributes: nil
////        )
////        
////        return path + "/db.sqlite"
////    }
////}
//
//final class CuisineM {
//    static let id_e = Expression<Int64>("id")
//    static let name_e = Expression<String>("name")
//    
//    static let table = Table("cuisines")
//    
//    static func create(db: Connection) throws {
//        try db.run(table.create {t in
//            t.column(id_e, primaryKey: true)
//            t.column(name_e)
//        })
//    }
//}
//
//struct Kal: Codable {
//    let name: String
//    let id: Int64
//}
//
//func zz() {
//    let kal = Kal(name: "", id: 0)
//    
//    Kal.self.de
//}
//
//struct RecipeExpr {
//    static let id_e = Expression<Int64>("id")
//    let id: Int64
//    
//    static let name_e = Expression<String>("name")
//    let name: String
//    
//    static let description_e = Expression<String>("description")
//    let description: String
//    
//    static let servings = Expression<Int64>("sevings")
//    let servings: Int64
//    
//    static let cook_time = Expression<Double>("cook_time")
//    let cook_time: Double
//    
//    static let likes = Expression<Int64>("likes")
//    let
//    
//    static let dislikes = Expression<Int64>("dislikes")
//    static let agg_rating = Expression<Double>("agg_rating")
//    
//    static let cuisine = Expression<Int64>("cuisine_id")
//    
//    static let table = Table("recipes")
//    
//    static func create(db: Connection) throws {
//        try db.run(table.create { t in
//            t.column(id_e, primaryKey: true)
//            t.column(name_e)
//            t.column(description_e)
//            t.column(servings_e)
//        })
//    }
//}
//
//final class IngredientExpr {
//    static let id = Expression<Int64>("id")
//    static let name = Expression<String>("name")
//    static let measure = Expression<String>("measure")
//    
//    static let table = Table("ingredients")
//    
//    static func create(db: Connection) throws {
//        try db.run(table.create { t in
//            t.column(id, primaryKey: true)
//            t.column(name)
//            t.column(measure)
//        })
//    }
//}
//
//final class Step
//
//final class ImmutableDB {
//    func schema() {
//        let recipes_table = Table("recipes")
//        let
//        try c.execute("""
//            create table if not exists recipes (
//                id integer primary key autoincrement,
//                name text,
//                
//                description text,
//                final_hint text,
//                servings integer,
//                cook_time_m double,
//                likes integer,
//                dislikes integer,
//                agg_rating double,
//                cover_img integer,
//                
//                foreign key (cover_img) references images(id)
//            );
//        
//            create table if not exists ingredients (
//                id integer primary key autoincrement,
//                name text,
//                unit text
//            );
//        
//            create table if not exists step (
//                id integer primary key autoincrement,
//                title text,
//                content text,
//                image integer,
//        
//                foreign key (image) references images(id)
//            );
//        
//            create table if not exists cuisine (
//                id integer primary key autoincrement,
//                name text
//            );
//        
//            create table if not exists recipe_step (
//                r_id integer not null,
//                s_id integer not null,
//                pos integer not null,
//        
//                foreign key (r_id) references recipes(id),
//                foreign key (s_id) references steps(id)
//            );
//        
//            create table if not exists recipe_ingredient (
//                r_id integer not null,
//                ing_id integer not null,
//                amount double not null,
//        
//                foreign key (r_id) references recipes(id),
//                foreign key (ing_id) references ingredients(id)
//            );
//        
//            create table if not exists images (
//                id integer primary key autoincrement,
//                name text unique not null,
//                data blob
//            );
//        """)
//    }
//}
