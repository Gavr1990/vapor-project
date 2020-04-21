import FluentSQLite
import Vapor

final class Todo: SQLiteModel {
    var id: Int?

    var title: String
    
    var userID: User.ID

    init(id: Int? = nil, title: String, userID: User.ID) {
        self.id = id
        self.title = title
        self.userID = userID
    }
}

extension Todo {
    var user: Parent<Todo, User> {
        return parent(\.userID)
    }
}

extension Todo: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Todo.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Todo: Content { }

extension Todo: Parameter { }
