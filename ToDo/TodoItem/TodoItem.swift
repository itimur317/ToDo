//
//  TodoItem.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import Foundation


struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadlineAt: Date? // deadline
    let isDone: Bool // done
    let createdAt: Date // created_at
    let changedAt: Date? // changed_at
    
    init(id: String = UUID().uuidString, text: String,
         importance: Importance, deadlineAt: Date? = nil,
         isDone: Bool, createdAt: Date, changedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadlineAt = deadlineAt
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}


extension TodoItem {
    static func fixture(
        id: String = "",
        text: String = "",
        importance: Importance,
        deadlineAt: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(timeIntervalSince1970: 100),
        changedAt: Date? = nil) -> TodoItem {
            return .init(id: id,
                         text: text,
                         importance: importance,
                         deadlineAt: deadlineAt,
                         isDone: isDone,
                         createdAt: createdAt,
                         changedAt: changedAt)
        }
}
