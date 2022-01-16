//
//  File.swift
//  
//
//  Created by Finer  Vine on 2022/1/16.
//

import Fluent
import Vapor

struct FileListController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let files = routes.grouped("files")
        files.get(use: site)
        files.get("path", use: readDirectory)
        
        // 这里是受保护路由
        let protectedRoutes = files
        protectedRoutes.get("sub-path", use: readSubpathsDirectory)
        protectedRoutes.get("delete", use: deletePathFile)
    }
    
    // 页面信息
    func site(req: Request) async throws -> View {
        return try await req.view.render("FileManager/index.html")
    }
    
    /**
     目录信息: http://127.0.0.1:8080/files/path?value=./
     */
    func readDirectory(req: Request) async throws -> [String] {
        let path = try req.query.get(String.self, at: "value")
        return try readContentOfDirectory(atPath: path)
    }
    
    /**
     目录信息: http://127.0.0.1:8080/files/sub-path?value=./
     */
    func readSubpathsDirectory(req: Request) async throws -> [String] {
        guard let path = req.query[String.self, at: "value"] else {
            throw Abort(.badRequest)
        }
        guard let infos = readSubpathsOfDirectory(atPath: path) else {
            throw Abort(.badRequest)
        }
        return infos
    }
    
    /**
     删除信息: http://127.0.0.1:8080/files/delete?value=./
     */
    func deletePathFile(req: Request) async throws -> [String] {
        guard let path: String = req.query["value"] else {
            throw Abort(.badRequest)
        }
        return try deleteItem(atPath: path)
    }
    
    /// 从指定目录读取文件
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 文件信息
    func readContentOfDirectory(atPath path:String) throws -> [String] {
        let manager = FileManager.default
        let contentsOfPath = try manager.contentsOfDirectory(atPath: path)
        return contentsOfPath
    }
    
    /// 深度遍历，来展示目录下的所有文件
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 文件信息
    func readSubpathsOfDirectory(atPath path:String) -> [String]? {
        let manager = FileManager.default
        let contentsOfPath = manager.subpaths(atPath: path)
        return contentsOfPath
    }
    
    /// 删除文件或者文件夹 并返回文件或者文件夹信息
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 文件信息
    func deleteItem(atPath path: String) throws -> [String] {
        let manager = FileManager.default
        let msgs = try manager.attributesOfItem(atPath: path).map { (info) -> String in
            return "key: \(info.key) value:\(info.value)"
        }
        try manager.removeItem(atPath: path)
        return msgs
    }
}
