//
//  TodoItem+Fixture.swift
//  ToDoTests
//
//  Created by Timur on 31.07.2022.
//

import XCTest
@testable import TodoItem

extension TodoItem {
    static func fixture(
        id: String = "",
        text: String = "",
        importance: Importance,
        deadlineAt: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(timeIntervalSince1970: 100),
        changedAt: Date? = nil) -> TodoItem {
            return .init(text: text,
                         importance: importance,
                         isDone: isDone,
                         createdAt: createdAt,
                         id: id,
                         deadlineAt: deadlineAt,
                         changedAt: changedAt)
        }
}
