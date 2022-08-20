//
//  Service.swift
//  ToDo
//
//  Created by Timur on 20.08.2022.
//

import TodoItem

final class Service {
    
    var itemsUpdated: (() -> Void)?
    
    private let networkService = DefaultNetworkService()
    private let mockFileCacheService = MockFileCacheService()
    
    private var items: [String: TodoItem] = [:]
    
    private var isDirty: Bool = false
    
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        networkService.getAllTodoItems { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let todoItems):
                todoItems.forEach { item in
                    self.items[item.id] = item
                }
                completion(.success(todoItems))
            case .failure(let error):
                print(error.localizedDescription)
                self.items = [:]
                self.isDirty = true
                completion(.failure(error))
            }
        }
    }
    
    func addTodoItem(
        _ todoItem: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        if isDirty {
            updateAllTodoItems()
        }
        
        networkService.addTodoItem(todoItem) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let returnedItem):
                self.items[returnedItem.id] = returnedItem
                completion(.success(returnedItem))
            case .failure(let error):
                print(error.localizedDescription)
                self.items[todoItem.id] = todoItem
                self.isDirty = true
                completion(.failure(error))
            }
        }
    }
    
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        if isDirty {
            updateAllTodoItems()
        }
        
        networkService.deleteTodoItem(at: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let returnedItem):
                self.items[returnedItem.id] = nil
                completion(.success(returnedItem))
            case .failure(let error):
                print(error.localizedDescription)
                self.items[id] = nil
                self.isDirty = true
                completion(.failure(error))
            }
        }
    }
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        if isDirty {
            updateAllTodoItems()
        }
        
        networkService.editTodoItem(at: id, to: item) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let returnedItem):
                self.items[id] = returnedItem
                completion(.success(returnedItem))
            case .failure(let error):
                print(error.localizedDescription)
                self.items[id] = item
                self.isDirty = true
                completion(.failure(error))
            }
        }
    }
    
    func updateAllTodoItems() {
        networkService.updateAllTodoItems(
            items.values.map { $0 as TodoItem }
        ) { result in
            switch result {
            case .success(let todoItems):
                self.items.keys.forEach { key in
                    self.items[key] = nil
                }
                
                todoItems.forEach { item in
                    self.items[item.id] = item
                }
                self.isDirty = false
                _ = self.itemsUpdated
            case .failure(let error):
                print(error.localizedDescription)
                self.isDirty = true
            }
        }
    }
}
