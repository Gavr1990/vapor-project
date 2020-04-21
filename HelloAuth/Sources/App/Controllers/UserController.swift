import Crypto
import Vapor
import FluentSQLite

final class UserController {
    func login(_ req: Request) throws -> Future<UserToken> {
        let user = try req.requireAuthenticated(User.self)
        
        let token = try UserToken.create(userID: user.requireID())
        
        return token.save(on: req)
    }
    
    func create(_ req: Request) throws -> Future<UserResponse> {
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            guard user.password == user.verifyPassword else {
                throw Abort(.badRequest, reason: "Password and verification must match.")
            }
            
            let hash = try BCrypt.hash(user.password)
            return User(id: nil, name: user.name, email: user.email, passwordHash: hash)
                .save(on: req)
        }.map { user in
            return try UserResponse(id: user.requireID(), name: user.name, email: user.email)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        _ = try req.requireAuthenticated(User.self)
        
        return try req.parameters.next(User.self).flatMap { user -> Future<Void> in

            return user.delete(on: req)
        }.transform(to: .ok)
    }

}

// MARK: Content

struct CreateUserRequest: Content {
    var name: String
    
    var email: String
    
    var password: String
    
    var verifyPassword: String
}

struct UserResponse: Content {
    var id: Int
    
    var name: String
    
    var email: String
}
