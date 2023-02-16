//
//  File.swift
//  
//
//  Created by Finer  Vine on 2022/1/16.
//

import Fluent
import Vapor

struct CollectFileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let collect = routes.grouped("collect")
        collect.get(use: index)
        collect.on(.POST,body: .collect(maxSize: 10_000_000), use: upload)
    }
    
    //
    func index(req: Request) throws -> EventLoopFuture<[CollectModel]> {
        return CollectModel.query(on: req.db).all()
    }
    
    //
    func upload(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let image = try req.content.decode(CollectModel.self)
        let saved = image.save(on: req.db)
        let statusPromise = req.eventLoop.makePromise(of: HTTPStatus.self)

        
        saved.whenComplete { someResult in
            switch someResult {
            case .success:
                let imageName = image.id?.uuidString ?? "unknown image"
                do {
                    try self.saveFile(name: imageName, data: image.data)
                } catch {
                    req.logger.critical("failed to save file for image \(imageName)")
                    statusPromise.succeed(.internalServerError)
                }
                statusPromise.succeed(.ok)
            case .failure(let error):
                req.logger.critical("failed to save file \(error.localizedDescription)")
                statusPromise.succeed(.internalServerError)
            }
            statusPromise.succeed(.ok)
        }
        return statusPromise.futureResult
    }
}

extension CollectFileController {
    fileprivate func saveFile(name: String, data: Data) throws {
        let path = FileManager.default
            .currentDirectoryPath.appending("/\(name)")
        if FileManager.default.createFile(atPath: path,
                                          contents: data,
                                          attributes: nil) {
            debugPrint("saved file\n\t \(path)")
        } else {
            throw FileError.couldNotSave
        }
    }
}

enum FileError: Error {
    case couldNotSave
}

