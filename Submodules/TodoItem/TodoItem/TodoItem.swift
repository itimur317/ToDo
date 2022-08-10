//
//  TodoItem.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import Foundation

public struct TodoItem {
    public let id: String
    public let text: String
    public let importance: Importance
    public let deadlineAt: Date? // deadline
    public let isDone: Bool // done
    public let createdAt: Date // created_at
    public let changedAt: Date? // changed_at
    
    public init(
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
