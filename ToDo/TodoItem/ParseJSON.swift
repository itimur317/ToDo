//
//  ParseJSON.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import Foundation


protocol ParsingJsonProtocol {
    static func parse(json: Any) -> TodoItem?
    var json: Any { get }
}

extension TodoItem: ParsingJsonProtocol {
    
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        
        return TodoItem(from: dict)
    }
    
    var json: Any {
        var dict: [String: Any] = [
            Key.id.rawValue: id,
            Key.text.rawValue: text,
            Key.isDone.rawValue: isDone,
            Key.createdAt.rawValue: createdAt.timeIntervalSince1970,
        ]
        
        if !importance.isBasic() {
            dict[Key.importance.rawValue] = importance.rawValue
        }
        
        if let deadlineAt = deadlineAt {
            dict[Key.deadlineAt.rawValue] = deadlineAt.timeIntervalSince1970
        }
        
        if let changedAt = changedAt {
            dict[Key.changedAt.rawValue] = changedAt.timeIntervalSince1970
        }
        
        return dict as Any
    }
    
    enum Key: String {
        case id
        case text
        case importance
        case deadlineAt = "deadline"
        case isDone = "done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
    }
}


// MARK: - parse JSON tools

extension TodoItem {
    
    private init?(from dict: [String: Any]) {
        guard let id = dict[Key.id.rawValue] as? String,
              let text = dict[Key.text.rawValue] as? String,
              let isDone = dict[Key.isDone.rawValue] as? Bool else {
                  return nil
              }
        
        guard let importance = TodoItem.getImportance(using: dict) else {
            return nil
        }
        
        let deadlineAt = TodoItem.getDate(from: Key.deadlineAt, using: dict)
        
        guard let createdAt = TodoItem.getDate(from: Key.createdAt, using: dict) else {
            return nil
        }
        
        let changedAt = TodoItem.getDate(from: Key.changedAt, using: dict)
        
        
        // проверка на то, что изменения будут позже, чем создание
        if let changedAt = changedAt, changedAt < createdAt {
            return nil
        }
        
        // проверка на то, что дедлайн будет позже, чем создание
        if let deadlineAt = deadlineAt, deadlineAt < createdAt {
            return nil
        }
        
        self.init(id: id, text: text,
                  importance: importance, deadlineAt: deadlineAt,
                  isDone: isDone, createdAt: createdAt, changedAt: changedAt)
    }
    
    
    private static func getImportance(using dict: [String: Any]) -> Importance? {
        // Если не получилось достать, то там nil => .basic
        guard let importanceAny = dict[Key.importance.rawValue] else {
            return .basic
        }
        
        // Если получилось достать, но "важность" не строковая(что-то не то) => nil
        guard let importanceString = importanceAny as? String else {
            return nil
        }
        
        switch importanceString {
        case Importance.low.rawValue:
            return .low
        case Importance.important.rawValue:
            return .important
            // важность не низкого приоритета
            // и не высокого приоритета => что-то не то
        default:
            return nil
        }
    }
    
    private static func getDate(from key: Key, using dict: [String: Any]) -> Date? {
        guard let dateAtDouble = dict[key.rawValue] as? Double?,
              let date = TodoItem.getDate(from: dateAtDouble) else {
                  return nil
              }
        
        return date
    }
    
    private static func getDate(from seconds: Double?) -> Date? {
        guard let seconds = seconds, seconds > 0 else {
            return nil
        }
        return Date(timeIntervalSince1970: seconds)
    }
}



