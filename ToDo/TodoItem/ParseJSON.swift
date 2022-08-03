//
//  ParseJSON.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import Foundation

extension TodoItem {
    
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        return TodoItem(from: dict)
    }
    
    var json: Any {
        var dict: [String: Any] = [
            KeyTodoItem.id: id,
            KeyTodoItem.text: text,
            KeyTodoItem.isDone: isDone,
            KeyTodoItem.createdAt: createdAt.timeIntervalSince1970,
        ]
        
        if importance != .basic {
            dict[KeyTodoItem.importance] = importance.rawValue
        }
        
        if let deadlineAt = deadlineAt {
            dict[KeyTodoItem.deadlineAt] = deadlineAt.timeIntervalSince1970
        }
        
        if let changedAt = changedAt {
            dict[KeyTodoItem.changedAt] = changedAt.timeIntervalSince1970
        }
        
        return dict
    }
}

// MARK: - parse JSON
extension TodoItem {
    private init?(from dict: [String: Any]) {
        guard
            let id = dict[KeyTodoItem.id] as? String,
            let text = dict[KeyTodoItem.text] as? String,
            let createdAt = ((dict[KeyTodoItem.createdAt] as? Double).flatMap {
                Date(timeIntervalSince1970: TimeInterval($0))
            }) else {
                return nil
            }
        
        let isDone = dict[KeyTodoItem.isDone] as? Bool ?? false
        let importance = (dict[KeyTodoItem.importance] as? String).flatMap(Importance.init) ?? .basic
        
        let changedAt = (dict[KeyTodoItem.changedAt] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }
        let deadlineAt = (dict[KeyTodoItem.deadlineAt] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
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
}
