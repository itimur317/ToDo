//
//  TodoItem+Extension.swift
//  ToDo
//
//  Created by Timur on 23.08.2022.
//

import TodoItem
import CoreData

// MARK: - TodoItem extension for CoreData

extension TodoItem {
    enum TodoItemError: Error {
        case failureParseNSManagedObject
    }
    
    init(from managedObject: NSManagedObject) throws {
        guard let text = managedObject.value(forKey: DefaultFileCacheService.Key.text) as? String,
              let importanceString = managedObject.value(forKey: DefaultFileCacheService.Key.importance) as? String,
              let importance = Importance(rawValue: importanceString),
              let isDone = managedObject.value(forKey: DefaultFileCacheService.Key.isDone) as? Bool,
              let createdAt = managedObject.value(forKey: DefaultFileCacheService.Key.createdAt) as? Date,
              let id = managedObject.value(forKey: DefaultFileCacheService.Key.id) as? String,
              let deadlineAt = managedObject.value(forKey: DefaultFileCacheService.Key.deadlineAt) as? Date?,
              let changedAt = managedObject.value(forKey: DefaultFileCacheService.Key.changedAt) as? Date? else {
                  throw TodoItemError.failureParseNSManagedObject
              }
        self.init(
            text: text,
            importance: importance,
            isDone: isDone,
            createdAt: createdAt,
            id: id,
            deadlineAt: deadlineAt,
            changedAt: changedAt
        )
    }
    
    var managedObject: NSManagedObject {
        let item = TodoItemEntity()
        setValues(to: item)
        return item
    }
    
    func setValues(to item: NSManagedObject) {
        item.setValue(id, forKeyPath: DefaultFileCacheService.Key.id)
        item.setValue(text, forKeyPath: DefaultFileCacheService.Key.text)
        item.setValue(importance.rawValue, forKeyPath: DefaultFileCacheService.Key.importance)
        item.setValue(isDone, forKeyPath: DefaultFileCacheService.Key.isDone)
        item.setValue(deadlineAt, forKeyPath: DefaultFileCacheService.Key.deadlineAt)
        item.setValue(changedAt, forKeyPath: DefaultFileCacheService.Key.changedAt)
        item.setValue(createdAt, forKeyPath: DefaultFileCacheService.Key.createdAt)
    }
    
    static func map(from dto: TodoItemNetworkModel) -> TodoItem {
        guard let deadlineAt = dto.deadlineAt else {
            return TodoItem(
                text: dto.text,
                importance: Importance(rawValue: dto.importance) ?? .basic,
                isDone: dto.isDone,
                createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createdAt)),
                id: dto.id,
                deadlineAt: nil,
                changedAt: Date(timeIntervalSince1970: TimeInterval(dto.changedAt))
            )
        }
        
        return TodoItem(
            text: dto.text,
            importance: Importance(rawValue: dto.importance) ?? .basic,
            isDone: dto.isDone,
            createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createdAt)),
            id: dto.id,
            deadlineAt: Date(timeIntervalSince1970: TimeInterval(deadlineAt)),
            changedAt: Date(timeIntervalSince1970: TimeInterval(dto.changedAt))
        )
    }
}
