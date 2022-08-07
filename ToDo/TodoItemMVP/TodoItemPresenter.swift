//
//  TodoItemPresenter.swift
//  ToDo
//
//  Created by Timur on 31.07.2022.
//

import Foundation

protocol TodoItemPresenterProtocol: AnyObject {
    var text: String? { get set }
    var deadlineAt: Date? { get set }
    var willSaveDeadline: Bool { get set }
    var importance: Importance? { get set }
    
    func cancelEdit()
    func saveTodoItem()
    func deleteTodoItem()
}

enum AddTodoItemError: Error {
    case failureDelete
    case failureAdd
}

enum OpenTodoItem {
    case createNew
    case edit(todoItem: TodoItem)
}

final class TodoItemPresenter: TodoItemPresenterProtocol {
    
    weak var todoItemVC: TodoItemVCProtocol?
    
    var text: String?
    var importance: Importance?
    var deadlineAt: Date?
    
    var willSaveDeadline: Bool = false
    
    private var isDone: Bool?
    private var createdAt: Date?
    private var id: String?
    private let fileCache = FileCache()
    
    private let isEditing: Bool
    private let dir: String

    init(to action: OpenTodoItem, in dir: String) {
        self.dir = dir
        
        switch action {
        case .createNew:
            isEditing = false
        case .edit(let todoItem):
            isEditing = true
            
            text = todoItem.text
            importance = todoItem.importance
            isDone = todoItem.isDone
            createdAt = todoItem.createdAt
            id = todoItem.id
            deadlineAt = todoItem.deadlineAt
            
            if deadlineAt != nil {
                willSaveDeadline = true
            }
        }
    }
    
    func cancelEdit() {
        todoItemVC?.dismiss()
    }
    
    func saveTodoItem() {
        guard
            let text = text,
            let importance = importance
        else {
            todoItemVC?.failureSaveTodoItem()
            return
        }
        if !willSaveDeadline {
            deadlineAt = nil
        }
        
        let todoItem = TodoItem(
            text: text,
            importance: importance,
            isDone: isDone ?? false,
            createdAt: createdAt ?? Date(),
            deadlineAt: deadlineAt
        )
        
        // Если это дело в кэше, то оно удалиться,
        // чтобы занести это же дело с изменениями(и с другим id)
        
        if isEditing {
            guard
                let id = id,
                (try? fileCache.load(from: dir)) != nil,
                (try? fileCache.add(todoItem: todoItem)) != nil,
                (try? fileCache.delete(id: id)) != nil,
                (try? fileCache.clearCache(by: dir)) != nil,
                (try? fileCache.save(to: dir)) != nil
            else {
                todoItemVC?.failureSaveTodoItem()
                return
            }
        }
        else {
            guard
                (try? fileCache.load(from: dir)) != nil,
                (try? fileCache.add(todoItem: todoItem)) != nil,
                (try? fileCache.clearCache(by: dir)) != nil,
                (try? fileCache.save(to: dir)) != nil
            else {
                todoItemVC?.failureSaveTodoItem()
                return
            }
        }
        
        
        todoItemVC?.successSaveTodoItem()
    }
    
    func deleteTodoItem() {
        guard let id = id else {
            todoItemVC?.failureDeleteTodoItem()
            return
        }
        do {
            try fileCache.load(from: dir)
            try fileCache.delete(id: id)
            try fileCache.clearCache(by: "Main")
            try fileCache.save(to: dir)
        }
        catch {
            todoItemVC?.failureDeleteTodoItem()
        }
        todoItemVC?.successDeleteTodoItem()
    }
}
