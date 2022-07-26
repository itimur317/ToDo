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
        let a = 2
        return a
    }
}


// MARK: - parse JSON tools

extension TodoItem {
    
    init?(from dict: [String: Any]) {
        
        guard let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let importanceString = dict["importance"] as? String,
              let deadlineAtDouble = dict["deadline"] as? Double?,
              let isDone = dict["done"] as? Bool,
              let createdAtDouble = dict["created_at"] as? Double,
              let changedAtDouble = dict["changed_at"] as? Double? else {
                  return nil
              }
        
        guard let createdAt = TodoItem.getDate(from: createdAtDouble),
              let importance = TodoItem.getImportance(from: importanceString) else {
                  return nil
              }
        
        let deadlineAt = TodoItem.getDate(from: deadlineAtDouble)
        let changedAt = TodoItem.getDate(from: changedAtDouble)
        
        self.init(id: id, text: text,
                  importance: importance, deadlineAt: deadlineAt,
                  isDone: isDone, createdAt: createdAt, changedAt: changedAt)
    }
    
    
    private static func getImportance(from string: String) -> Importance? {
        var importance: Importance
        
        switch string {
        case Importance.low.rawValue:
            importance = .low
        case Importance.low.rawValue:
            importance = .basic
        case Importance.low.rawValue:
            importance = .important
        default:
            return nil
        }
        
        return importance
    }
    
    
    private static func getDate(from seconds: Double?) -> Date? {
        guard let seconds = seconds, seconds > 0 else {
            return nil
        }
        return Date(timeIntervalSince1970: seconds)
    }
}
