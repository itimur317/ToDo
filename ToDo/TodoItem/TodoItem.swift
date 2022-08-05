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
    
    init(
        text: String,
        importance: Importance,
        isDone: Bool,
        createdAt: Date,
        id: String = UUID().uuidString,
        deadlineAt: Date? = nil,
        changedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadlineAt = deadlineAt
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}
