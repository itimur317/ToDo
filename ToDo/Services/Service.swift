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
    private let fileCacheService = DefaultFileCacheService()
    
    private var items: [String: TodoItem] = [:]
    
    private var isDirty: Bool = false
    
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        // Достаем все локальные дела
        fileCacheService.load { result in
            switch result {
            case .success(let todoItems):
                // Заполняем items
                todoItems.forEach { item in
                    self.items[item.id] = item
                }
                completion(.success(todoItems))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        // Достаем все дела по сети
        networkService.getAllTodoItems { [weak self] result in
            guard let self = self else { return }
            
            // Запускаем индикатор
            if self.requestStarted != nil {
                self.requestStarted!()
            }
            
            switch result {
            case .success(let todoItems):
                // Добавляем для дальнейшего патча уникальные и те,
                // которые обновлялись позднее
                for item in todoItems {
                    guard let itemInFileCache = self.items[item.id] else {
                        // Если такого не было в кэше
                        // добавим в коллекцию для синка
                        // + добавим в кэш
                        self.fileCacheService.insert(item) { result in
                            switch result {
                            case .success(let returnedItem):
                                self.items[returnedItem.id] = returnedItem
                            case .failure:
                                self.items[item.id] = item
                            }
                        }
                        continue
                    }
                    
                    // Если такой был в кэше, то сравниваем даты изменения
                    // Если в сети оказался новее, то сохраняем его
                    if
                        let networkChangedAt = item.changedAt?.timeIntervalSince1970,
                        let fileCacheChangedAt = itemInFileCache.changedAt?.timeIntervalSince1970,
                        networkChangedAt > fileCacheChangedAt {
                        // Удалим старый
                        let oldId = itemInFileCache.id
                        self.items[oldId] = nil
                        
                        // Добавим новый в коллекцию для синка
                        self.fileCacheService.editTodoItem(at: oldId, to: item) { result in
                            switch result {
                            case .success(let editedItem):
                                self.items[editedItem.id] = editedItem
                            case .failure:
                                self.items[item.id] = item
                            }
                        }
                    }
                }
                
                // Смешанные из сети и кэша дела отправляем на синк
                DispatchQueue.main.async {
                    self.updateIfNeeded()
                    // Теперь на сети и на таблице будут синканные данные
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.isDirty = true
            }
        }
    }
    
    func addTodoItem(
        _ todoItem: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        fileCacheService.insert(todoItem) { result in
            switch result {
            case .success(let item):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        if requestStarted != nil {
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
        fileCacheService.delete(at: id) { result in
            switch result {
            case .success(let item):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        if requestStarted != nil {
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
        
        fileCacheService.editTodoItem(at: id, to: item) { result in
            switch result {
            case .success(let item):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        if requestStarted != nil {
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
            case .failure:
                self.isDirty = true
            }
        }
    }
    
    private func updateIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + networkService.timeout + 0.1) {
            self.updateAllTodoItems()
        }
    }
}
