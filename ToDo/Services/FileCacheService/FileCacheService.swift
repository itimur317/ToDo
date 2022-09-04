//
//  FileCacheService.swift
//  ToDo
//
//  Created by Timur on 12.08.2022.
//

import TodoItem
import CoreData

protocol FileCacheService: AnyObject {
    func insert(
        _ todoItem: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    
    func delete(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    
    func load(completion: @escaping (Result<[TodoItem], Error>) -> Void)
}

final class DefaultFileCacheService: FileCacheService {
    // Не делаю enum из пода публичным, т.к. имена
    // ключей могут не совпадать на сети и в БД
    enum Key {
        static let id = "id"
        static let text = "text"
        static let importance = "importance"
        static let deadlineAt = "deadline"
        static let isDone = "done"
        static let createdAt = "created_at"
        static let changedAt = "changed_at"
    }
    
    private let isolationQueue = DispatchQueue(
        label: "FileCacheServiceQueue",
        attributes: .concurrent
    )
    
    func insert(
        _ todoItem: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        isolationQueue.async(flags: .barrier) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            guard let entity =  NSEntityDescription.entity(
                forEntityName: "TodoItemEntity",
                in: managedContext
            ) else {
                return
            }
            
            let item = NSManagedObject(
                entity: entity,
                insertInto: managedContext
            )
            todoItem.setValues(to: item)
            
            do {
                try managedContext.save()
                DispatchQueue.main.async {
                    completion(.success((todoItem)))
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func delete(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        isolationQueue.async(flags: .barrier) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let predicate = NSPredicate(format: "\(Key.id) == %@", id)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoItemEntity")
            
            fetchRequest.predicate = predicate
            
            do {
                let objects = try managedContext.fetch(fetchRequest)
                if objects.count > 0 {
                    let objectToDelete = objects[0]
                    managedContext.delete(objectToDelete)
                    let todoItem = try TodoItem(from: objectToDelete)
                    
                    try managedContext.save()
                    DispatchQueue.main.async {
                        completion(.success(todoItem))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(TodoItem.TodoItemError.failureParseNSManagedObject))
                    }
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        isolationQueue.async(flags: .barrier) {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let predicate = NSPredicate(format: "\(Key.id) == %@", id)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoItemEntity")
            
            fetchRequest.predicate = predicate
            
            do {
                let objects = try managedContext.fetch(fetchRequest)
                if objects.count > 0 {
                    let objectToEdit = objects[0]
                    item.setValues(to: objectToEdit)
                    
                    try managedContext.save()
                    DispatchQueue.main.async {
                        completion(.success(item))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(TodoItem.TodoItemError.failureParseNSManagedObject))
                    }
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func load(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        isolationQueue.sync {
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "TodoItemEntity")
            
            do {
                let objects = try managedContext.fetch(fetchRequest)
                var itemsToReturn: [TodoItem] = []
                
                try objects.forEach { object in
                    let item = try TodoItem(from: object)
                    itemsToReturn.append(item)
                }
                DispatchQueue.main.async {
                    completion(.success(itemsToReturn))
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
