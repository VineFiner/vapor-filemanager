//
//  File.swift
//  
//
//  Created by Finer  Vine on 2022/1/16.
//

import Fluent

struct CreateStream: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(StreamModel.schema)
            .id()
            .field("fileName", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(StreamModel.schema).delete()
    }
}
