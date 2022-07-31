//
//  FileCache.swift
//  ToDo
//
//  Created by Timur on 28.07.2022.
//

import Foundation


protocol FileCacheProtocol: AnyObject {
    var items: [String: TodoItem] { get }
    
    // по ТЗ
    func add(todoItem: TodoItem) throws
    func delete(todoItem: TodoItem) throws
    func save(to dir: String) throws
    func load(from dir: String) throws
    
    // Полезные методы
    func contains(todoItem: TodoItem) -> Bool
    func clearCache(by name: String) throws
    func getAllFileNames(in dir: String) throws -> [String]
    func getAllDirNames() throws-> [String]
}


enum FileCacheError: Error {
    case failureDataToJson
    case failureParseTodoItem
    case failureCreatingDirectory
    case failureSaveTodoItem
    
    case alreadyContains
    case alreadyExists
    
    case notFound
}


final class FileCache {
    // Выбрал словарь потому что удобнее работать, чем с множествами
    // и протоколами Hashable для них
    // Массив при большом кол-во задач будет линейное время давать
    // [id: todoItem]
    private(set) var items: [String: TodoItem] = [:]
    
    private var fileManager = FileManager.default
}


extension FileCache: FileCacheProtocol {
    
    func add(todoItem: TodoItem) throws {
        let id = todoItem.id
        
        if items[id] != nil{
            throw FileCacheError.alreadyContains
        } else {
            items[id] = todoItem
        }
    }
    
    func delete(todoItem: TodoItem) throws {
        let id = todoItem.id
        
        if items[id] != nil {
            items[id] = nil
        } else {
            throw FileCacheError.notFound
        }
    }
        
    // Загрузить в файл по имени
    func save(to dir: String) throws {
        let dirUrl = getDirUrl(by: dir)
        
        // если нет директории, то cоздастся
        if !fileManager.fileExists(atPath: dirUrl.path) {
            do {
                try fileManager.createDirectory(
                    at: dirUrl,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                throw FileCacheError.failureCreatingDirectory
            }
        }
        
        for todoItem in items.values {
            do {
                try addToFile(
                    todoItem: todoItem,
                    to: dirUrl
                )
            } catch FileCacheError.failureSaveTodoItem {
                throw FileCacheError.failureSaveTodoItem
            }
        }
    }
    
    // Достать из файла по имени
    func load(from dir: String) throws {
        let dirUrl = getDirUrl(by: dir)
        
        guard let todoItemsId = try? getTodoItemsId(from: dirUrl) else {
            throw FileCacheError.notFound
        }
        
        items = [:]
        
        for id in todoItemsId {
//            let jsonIndexStart = id.index(
//                id.endIndex,
//                offsetBy: -5
//            )
//            let idWithoutJson = String(id[..<jsonIndexStart])
            let todoItem = try getTodoItem(
                from: dirUrl,
                by: id
            )
            items[todoItem.id] = todoItem
        }
    }
    
    func contains(todoItem: TodoItem) -> Bool {
        items.keys.contains(todoItem.id)
    }
        
    func clearCache(by name: String) throws {
        let dirUrl = getDirUrl(by: name)
        
        if fileManager.fileExists(atPath: dirUrl.path) {
            do {
                try fileManager.removeItem(at: dirUrl)
            } catch {
                throw FileCacheError.notFound
            }
        }
    }
        
    func getAllFileNames(in dir: String) throws -> [String] {
        let dirUrl = getDirUrl(by: dir)
        guard let allFileNames = try? fileManager.contentsOfDirectory(atPath: dirUrl.path) else {
            throw FileCacheError.notFound
        }
        
        return allFileNames
    }
        
    func getAllDirNames() throws -> [String] {
        let urls = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        guard let cachesDirectoryUrl = urls.first,
              let allDirNames = try? fileManager.contentsOfDirectory(atPath: cachesDirectoryUrl.path) else {
            throw FileCacheError.notFound
        }
        
        return allDirNames
    }
        
    private func getDirUrl(by dir: String) -> URL {
        let urls = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        let cachesDirectoryUrl = urls[0]
        
        return cachesDirectoryUrl.appendingPathComponent("\(dir)")
    }
        
    private func addToFile(todoItem: TodoItem, to dir: URL) throws {
        
        guard let data = try? JSONSerialization.data(
            withJSONObject: todoItem.json,
            options: .fragmentsAllowed
        ) else {
            throw FileCacheError.failureDataToJson
        }
        
        let fileUrl = dir.appendingPathComponent("\(todoItem.id).json")
        
        guard let _ = try? data.write(to: fileUrl) else {
            throw FileCacheError.failureSaveTodoItem
        }
    }
        
    private func getTodoItemsId(from dirUrl: URL) throws -> [String] {
        guard fileManager.fileExists(atPath: dirUrl.path),
              let todoItemsId = try? fileManager.contentsOfDirectory(atPath: dirUrl.path) else {
                  throw FileCacheError.notFound
              }
        
        return todoItemsId
    }
        
    private func getTodoItem(from dirUrl: URL, by id: String) throws -> TodoItem {
        let fileUrl = dirUrl.appendingPathComponent("\(id)")
        guard let data = try? Data(contentsOf: fileUrl) else {
            throw FileCacheError.notFound
        }
        
        guard let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .fragmentsAllowed
        ) else {
            throw FileCacheError.failureDataToJson
        }
        
        guard let todoItem = TodoItem.parse(json: json) else {
            throw FileCacheError.failureParseTodoItem
        }
        
        return todoItem
    }
        
   
}
