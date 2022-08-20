//
//  TodoItem+Extension.swift
//  TodoItem
//
//  Created by Timur on 20.08.2022.
//

import Foundation

public extension TodoItem {
    func asCompleted() -> TodoItem {
        return TodoItem(
            text: text,
            importance: importance,
            isDone: true,
            createdAt: createdAt,
            id: id,
            deadlineAt: deadlineAt,
            changedAt: changedAt
        )
    }
    
    func changed(at date: Date) -> TodoItem {
        return TodoItem(
            text: text,
            importance: importance,
            isDone: isDone,
            createdAt: createdAt,
            id: id,
            deadlineAt: deadlineAt,
            changedAt: date
        )
    }
}
