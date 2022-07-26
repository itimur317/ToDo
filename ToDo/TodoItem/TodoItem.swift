//
//  TodoItem.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import Foundation


struct TodoItem {
    enum Importance: String {
        case low, basic, important
    }
    
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

