//
//  FileCacheService.swift
//  ToDo
//
//  Created by Timur on 12.08.2022.
//

import Foundation
import TodoItem

protocol FileCacheService: AnyObject {
    func save(
        to file: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
    func add(_ newItem: TodoItem)
    func delete(id: String)
}

final class MockFileCacheService: FileCacheService {
    
    func save(
        to file: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.global().async {
            // save to DB
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
    
    func add(_ newItem: TodoItem) {
        DispatchQueue.global().async {
            // add to DB
        }
    }
    
    func delete(id: String) {
        DispatchQueue.global().async {
            // delete by id
        }
    }
    
    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        DispatchQueue.global().async {
            let todoItem1 = TodoItem(
                text: "todoItem1",
                importance: .low,
                isDone: false,
                createdAt: Date()
            )
            let todoItem2 = TodoItem(
                text: "todoItem2",
                importance: .low,
                isDone: false,
                createdAt: Date()
            )
            DispatchQueue.main.async {
                completion(.success([todoItem1, todoItem2]))
            }
        }
    }
}
