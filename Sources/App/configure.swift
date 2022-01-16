import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateCollect())
    app.migrations.add(CreateStream())
    
    
    app.views.use(.leaf)
    
    
    try app.autoMigrate().wait()
    
    let configuredDir = configureUploadDirectory(for: app)
    configuredDir.whenFailure { err in
        app.logger.error("Could not create uploads directory \(err.localizedDescription)")
    }
    configuredDir.whenSuccess { dirPath in
        app.logger.info("created upload directory at \(dirPath)")
    }
    
    // register routes
    try routes(app)
}
