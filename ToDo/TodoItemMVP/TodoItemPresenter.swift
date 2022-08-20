//
//  TodoItemPresenter.swift
//  ToDo
//
//  Created by Timur on 31.07.2022.
//

import Foundation
import TodoItem

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
    
    private let service: Service
    
    private let isEditing: Bool
    
    init(to action: OpenTodoItem, using storage: Service) {
        self.service = storage
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
            deadlineAt: deadlineAt,
            changedAt: Date()
        )
        
        // Если это дело в кэше, то оно удалиться,
        // чтобы занести это же дело с изменениями(и с другим id)
        if isEditing {
            saveWhenEditing(todoItem: todoItem)
        } else {
            saveWhenCreating(todoItem: todoItem)
        }
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
        
        service.deleteTodoItem(at: id) { [weak self] result in
            guard let self = self else {
                self?.todoItemVC?.failureDeleteTodoItem()
                return
            }
            
            switch result {
            case .success(_):
                self.todoItemVC?.successDeleteTodoItem()
            case .failure(_):
                self.todoItemVC?.failureDeleteTodoItem()
            }
        }
    }
    
    private func saveWhenEditing(todoItem: TodoItem) {
        guard let id = id else {
            todoItemVC?.failureSaveTodoItem()
            return
        }
        
        service.editTodoItem(
            at: id,
            to: todoItem
        ) { [weak self] result in
            guard let self = self else {
                self?.todoItemVC?.failureSaveTodoItem()
                return
            }
            
            switch result {
            case .success(_):
                self.todoItemVC?.successSaveTodoItem()
            case .failure(_):
                self.todoItemVC?.failureSaveTodoItem()
            }
        }
    }
    
    private func saveWhenCreating(todoItem: TodoItem) {
        
        service.addTodoItem(todoItem) { [weak self] result in
            guard let self = self else {
                self?.todoItemVC?.failureSaveTodoItem()
                return
            }
            
            switch result {
            case .success(_):
                self.todoItemVC?.successSaveTodoItem()
            case .failure(_):
                self.todoItemVC?.failureSaveTodoItem()
            }
        }
    }
}
