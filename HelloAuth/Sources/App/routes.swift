import Crypto
import Vapor

public func routes(_ router: Router) throws {
    let userController = UserController()
    router.post("users", use: userController.create)
    router.delete("users", User.parameter, use: userController.delete)
    
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("login", use: userController.login)
    
    let bearer = router.grouped(User.tokenAuthMiddleware())
    let todoController = TodoController()
    bearer.get("todos", use: todoController.index)
    bearer.post("todos", use: todoController.create)
    bearer.delete("todos", Todo.parameter, use: todoController.delete)
}
