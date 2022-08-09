//
//  TodoItemPresenter.swift
//  ToDo
//
//  Created by Timur on 31.07.2022.
//

import Foundation

protocol TodoItemPresenterProtocol: AnyObject {
    func getText() -> String?
    
    func setDeadline(_ deadlineAt: Date?)
    func getDeadline() -> Date?
    
    func setImportance(_ importance: Importance)
    func getImportance() -> Importance?
    
    func setWillSaveDeadline(_ willSave: Bool)
    func getWillSaveDeadline() -> Bool
    
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
    
    private var text: String?
    private var importance: Importance?
    private var deadlineAt: Date?
    
    private var willSaveDeadline: Bool = false
    
    private var isDone: Bool?
    private var createdAt: Date?
    private var id: String?
    
    private let fileCache = FileCache()
    
    private let isEditing: Bool
    private let dir: String

    init(to action: OpenTodoItem, in dir: String) {
        self.dir = dir
        importance = .basic
        
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
    
    func getText() -> String? {
        return text 
    }
    
    func setWillSaveDeadline(_ willSave: Bool) {
        willSaveDeadline = willSave
    }
    func getWillSaveDeadline() -> Bool {
        willSaveDeadline
    }
    
    func setImportance(_ importance: Importance) {
        self.importance = importance
    }
    func getImportance() -> Importance? {
        return importance
    }
    
    func setDeadline(_ deadlineAt: Date?) {
        self.deadlineAt = deadlineAt
    }
    func getDeadline() -> Date? {
        return deadlineAt
    }
    
    func cancelEdit() {
        todoItemVC?.dismiss()
    }
    
    func saveTodoItem() {
        text = todoItemVC?.getDescriptionText()
        
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
            saveWhenEditing(todoItem: todoItem)
        } else {
            saveWhenCreating(todoItem: todoItem)
        }
        
        todoItemVC?.successSaveTodoItem()
    }

    func deleteTodoItem() {
        if isEditing {
            deleteWhenEditing()
        } else {
            todoItemVC?.dismiss()
        }
    }
    
    private func deleteWhenEditing() {
        guard let id = id else {
            todoItemVC?.failureDeleteTodoItem()
            return
        }
        do {
            try fileCache.load(from: dir)
            try fileCache.delete(id: id)
            try fileCache.clearCache(by: dir)
            try fileCache.save(to: dir)
        } catch {
            todoItemVC?.failureDeleteTodoItem()
        }
        
        todoItemVC?.successDeleteTodoItem()
    }
    
    private func saveWhenEditing(todoItem: TodoItem) {
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
    
    private func saveWhenCreating(todoItem: TodoItem) {
        guard
//            (try? fileCache.load(from: dir)) != nil,
            (try? fileCache.add(todoItem: todoItem)) != nil,
//            (try? fileCache.clearCache(by: dir)) != nil,
            (try? fileCache.save(to: dir)) != nil
        else {
            todoItemVC?.failureSaveTodoItem()
            return
        }
    }
}
