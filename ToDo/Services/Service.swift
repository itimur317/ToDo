//
//  Service.swift
//  ToDo
//
//  Created by Timur on 20.08.2022.
//

import TodoItem

final class Service {
    
    var itemsUpdated: (([TodoItem]) -> Void)?
    var requestStarted: (() -> Void)?
    var requestStopped: (() -> Void)?
    
    private let networkService = DefaultNetworkService()
    private let mockFileCacheService = DefaultFileCacheService()
    
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
        if requestStarted != nil {
            completion(.success(todoItem))
            requestStarted!()
        }
        
        if self.isDirty {
            self.items[todoItem.id] = todoItem
            self.updateIfNeeded()
        } else {
            networkService.addTodoItem(todoItem) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let returnedItem):
                    guard self.requestStopped != nil else {
                        return
                    }
                    self.requestStopped!()
                    
                    self.items[returnedItem.id] = returnedItem
                case .failure(_):
                    self.isDirty = true
                    self.items[todoItem.id] = todoItem
                }
            }
        }
    }
    
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        
        if let item = self.items[id],
           requestStarted != nil {
            completion(.success(item))
            requestStarted!()
        }
        
        if self.isDirty {
            self.items[id] = nil
            self.updateIfNeeded()
        } else {
            networkService.deleteTodoItem(at: id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let returnedItem):
                    guard self.requestStopped != nil else {
                        return
                    }
                    self.requestStopped!()
                    // Удаление в сервисе
                    self.items[returnedItem.id] = nil
                case .failure(_):
                    guard self.items[id] != nil else {
                        return
                    }
                    self.isDirty = true
                    self.items[id] = nil
                }
            }
        }
    }
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        
        if requestStarted != nil {
            completion(.success(item))
            requestStarted!()
        }
        
        if self.isDirty {
            self.items[id] = item
            self.updateIfNeeded()
        } else {
            networkService.editTodoItem(at: id, to: item) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let returnedItem):
                    guard self.requestStopped != nil else {
                        return
                    }
                    self.requestStopped!()
                    self.items[id] = returnedItem
                case .failure(_):
                    guard self.items[id] != nil else {
                        return
                    }
                    self.isDirty = true
                    self.items[id] = item
                }
            }
        }
    }
    
    private func updateAllTodoItems() {
        networkService.updateAllTodoItems(
            items.values.map { $0 as TodoItem }
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let todoItems):
                self.items.keys.forEach { key in
                    self.items[key] = nil
                }
                
                todoItems.forEach { item in
                    self.items[item.id] = item
                }
                self.isDirty = false
                
                guard
                    self.itemsUpdated != nil,
                    self.requestStopped != nil else {
                        return
                    }
                
                self.itemsUpdated!(todoItems)
                self.requestStopped!()
            case .failure(_):
                self.isDirty = true
            }
        }
    }
    
    private func updateIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + networkService.timeout + 0.5) {
            self.updateAllTodoItems()
        }
    }
}
