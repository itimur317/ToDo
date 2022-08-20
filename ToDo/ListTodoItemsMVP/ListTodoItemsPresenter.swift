//
//  ListTodoItemsPresenter.swift
//  ToDo
//
//  Created by Timur on 04.08.2022.
//

import UIKit
import TodoItem

protocol ListTodoItemsPresenterProtocol: AnyObject {
    func viewDidLoad()
    
    func showHideDoneTodoItems()
    
    func getTodoItems() -> [TodoItem]
    func getTodoItemsCount() -> Int
    
    func deleteTodoItem(by: TodoItem)
    func markAsDone(todoItem: TodoItem)
    
    func createTodoItem()
    func editTodoItem(at: Int)
}

final class ListTodoItemsPresenter: ListTodoItemsPresenterProtocol {
    
    weak var listTodoItemsVC: ListTodoItemsVCProtocol?
    
    private let service = Service()
    private var items: [String: TodoItem] = [:]
    
    func viewDidLoad() {
        // для апдейта
        service.itemsUpdated = { [weak self] todoItems in
            guard let self = self else {
                return
            }
            
            self.items.keys.forEach { id in
                self.items[id] = nil
            }
            todoItems.forEach { item in
                self.items[item.id] = item
            }
            self.listTodoItemsVC?.updateTableView()
        }
        
        if !items.isEmpty {
            items.keys.forEach { key in
                items[key] = nil
            }
        }
        
        service.getAllTodoItems { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let todoItems):
                todoItems.forEach { todoItem in
                    self.items[todoItem.id] = todoItem
                }
                self.listTodoItemsVC?.updateTableView()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private var allTodoItems: [TodoItem] {
        items.values.sorted { todoItem1, todoItem2 in
            todoItem1.createdAt < todoItem2.createdAt
        }
    }
    
    private var notDoneTodoItems: [TodoItem] {
        allTodoItems.filter { todoItem in
            !todoItem.isDone
        }
    }
    
    private var isShowingAll: Bool = true
}

// MARK: - ListTodoItemsPresenterProtocol

extension ListTodoItemsPresenter {
    func showHideDoneTodoItems() {
        listTodoItemsVC?.updateShowHideLabel()
        isShowingAll = isShowingAll ? false : true
        listTodoItemsVC?.updateTableView()
    }
    
    func getTodoItems() -> [TodoItem] {
        if isShowingAll {
            return allTodoItems
        } else {
            return notDoneTodoItems
        }
    }
    
    func getTodoItemsCount() -> Int {
        listTodoItemsVC?.setDoneLabel(
            amount: allTodoItems.count - notDoneTodoItems.count)
        if isShowingAll {
            return allTodoItems.count
        } else {
            return notDoneTodoItems.count
        }
    }
    
    func deleteTodoItem(by todoItem: TodoItem) {
        let id = todoItem.id
        
        service.deleteTodoItem(at: id) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let returnedItem):
                self.items[returnedItem.id] = nil
                self.listTodoItemsVC?.updateTableView()
            case .failure(_):
                self.listTodoItemsVC?.alertWith(text: "Удалить не получилось!")
            }
        }
    }
    
    func markAsDone(todoItem: TodoItem) {
        let markedAsDoneTodoItem = todoItem.asCompleted()
        service.editTodoItem(
            at: todoItem.id,
            to: markedAsDoneTodoItem) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let returnedItem):
                    self.items[todoItem.id] = returnedItem
                    self.listTodoItemsVC?.updateTableView()
                case .failure(_):
                    self.listTodoItemsVC?.alertWith(text: "Не получилось отметить выполненным!")
                }
            }
    }
    
    func createTodoItem() {
        listTodoItemsVC?.presentToCreate(using: service)
    }
    
    func editTodoItem(at index: Int) {
        let todoItem = getTodoItems()[index]
        listTodoItemsVC?.presentToEdit(todoItem: todoItem, using: service)
    }
}
