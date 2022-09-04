//
//  TodoItemNetworkModel.swift
//  ToDo
//
//  Created by Timur on 18.08.2022.
//

import TodoItem

struct TodoItemNetworkModel: Codable {
    let id: String
    let text: String
    let importance: String
    let deadlineAt: Int?
    let isDone: Bool
    let createdAt: Int
    let changedAt: Int
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadlineAt = "deadline"
        case isDone = "done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case deviceId = "last_updated_by"
    }
    
    init(from todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        importance = todoItem.importance.rawValue
        
        if let deadline = todoItem.deadlineAt?.timeIntervalSince1970 {
            deadlineAt = Int(deadline)
        } else {
            deadlineAt = nil
        }
        
        isDone = todoItem.isDone
        createdAt = Int(todoItem.createdAt.timeIntervalSince1970)
        changedAt = Int((todoItem.changedAt ?? todoItem.createdAt).timeIntervalSince1970)
        deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    var todoItem: TodoItem {
        guard let deadlineAt = deadlineAt else {
            return TodoItem(
                text: text,
                importance: Importance(rawValue: importance) ?? .basic,
                isDone: isDone,
                createdAt: Date(timeIntervalSince1970: TimeInterval(createdAt)),
                id: id,
                deadlineAt: nil,
                changedAt: Date(timeIntervalSince1970: TimeInterval(changedAt))
            )
        }
        
        return TodoItem(
            text: text,
            importance: Importance(rawValue: importance) ?? .basic,
            isDone: isDone,
            createdAt: Date(timeIntervalSince1970: TimeInterval(createdAt)),
            id: id,
            deadlineAt: Date(timeIntervalSince1970: TimeInterval(deadlineAt)),
            changedAt: Date(timeIntervalSince1970: TimeInterval(changedAt))
        )
    }
}
