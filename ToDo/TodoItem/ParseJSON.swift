//
//  ParseJSON.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import Foundation

extension TodoItem {
    private enum Key {
        static let id = "id"
        static let text = "text"
        static let importance = "importance"
        static let deadlineAt = "deadline"
        static let isDone = "done"
        static let createdAt = "created_at"
        static let changedAt = "changed_at"
    }

    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        return TodoItem(from: dict)
    }
    
    var json: Any {
        var dict: [String: Any] = [
            Key.id: id,
            Key.text: text,
            Key.isDone: isDone,
            Key.createdAt: createdAt.timeIntervalSince1970
        ]
        
        if importance != .basic {
            dict[Key.importance] = importance.rawValue
        }
        
        if let deadlineAt = deadlineAt {
            dict[Key.deadlineAt] = deadlineAt.timeIntervalSince1970
        }
        
        if let changedAt = changedAt {
            dict[Key.changedAt] = changedAt.timeIntervalSince1970
        }
        
        return dict
    }
}

// MARK: - parse JSON

extension TodoItem {
    private init?(from dict: [String: Any]) {
        guard
            let id = dict[Key.id] as? String,
            let text = dict[Key.text] as? String,
            let createdAt = ((dict[Key.createdAt] as? Double).flatMap {
                Date(timeIntervalSince1970: TimeInterval($0))
            }) else {
                return nil
            }
        
        let isDone = dict[Key.isDone] as? Bool ?? false
        let importance = (dict[Key.importance] as? String).flatMap(Importance.init) ?? .basic
        
        let changedAt = (dict[Key.changedAt] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }
        let deadlineAt = (dict[Key.deadlineAt] as? Double).flatMap {
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
