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
        self.id = todoItem.id
        self.text = todoItem.text
        self.importance = todoItem.importance.rawValue
        self.deadlineAt = todoItem.deadlineAt.flatMap { Int($0.timeIntervalSince1970) }
        self.isDone = todoItem.isDone
        self.createdAt = Int(todoItem.createdAt.timeIntervalSince1970)
        self.changedAt = Int((todoItem.changedAt ?? todoItem.createdAt).timeIntervalSince1970)
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}
