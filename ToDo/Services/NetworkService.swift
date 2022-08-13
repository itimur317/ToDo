//
//  NetworkService.swift
//  ToDo
//
//  Created by Timur on 12.08.2022.
//

import Foundation
import TodoItem

protocol NetworkService: AnyObject {
    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) 
}

final class MockNetworkService: NetworkService {
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
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
    
    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async {
            let todoItem = TodoItem(
                text: "editedItem",
                importance: item.importance,
                isDone: item.isDone,
                createdAt: Date()
            )
            
            DispatchQueue.main.async {
                completion(.success(todoItem))
            }
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async {
            let todoItem = TodoItem(
                text: "deletedItem",
                importance: .basic,
                isDone: true,
                createdAt: Date()
            )
            DispatchQueue.main.async {
                completion(.success(todoItem))
            }
        }
    }
}
