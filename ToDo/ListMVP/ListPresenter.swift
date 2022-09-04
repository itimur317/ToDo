//
//  ListPresenter.swift
//  ToDo
//
//  Created by Timur on 04.08.2022.
//

import UIKit
import TodoItem

final class ListPresenter: ListPresenterProtocol {
    
    weak var listVC: ListVCProtocol?
    
    private let service = Service()
    private var items: [String: TodoItem] = [:]
    
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
    
    func viewDidLoad() {
        setServiceClosures()
        
        service.getAllTodoItems { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let todoItems):

                todoItems.forEach { todoItem in
                    self.items[todoItem.id] = todoItem
                }
                self.listVC?.updateTableView()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setServiceClosures() {
        service.itemsUpdated = { [weak self] todoItems in
            guard let self = self else {
                return
            }
            
            self.items.keys.forEach { id in
                self.items[id] = nil
            }
            
            for item in todoItems {
                self.items[item.id] = item
            }
            
            self.listVC?.updateTableView()
        }
        
        service.requestStarted = { [weak self] in
            self?.listVC?.startIndicator()
        }
        
        service.requestStopped = { [weak self] in
            self?.listVC?.stopIndicator()
        }
    }
}

// MARK: - ListPresenterProtocol

extension ListPresenter {
    func showHideDoneTodoItems() {
        listVC?.updateShowHideLabel()
        isShowingAll = isShowingAll ? false : true
        listVC?.updateTableView()
    }
    
    func getTodoItems() -> [TodoItem] {
        if isShowingAll {
            return allTodoItems
        } else {
            return notDoneTodoItems
        }
    }
    
    func getTodoItemsCount() -> Int {
        listVC?.setDoneLabel(
            amount: allTodoItems.count - notDoneTodoItems.count)
        if isShowingAll {
            return allTodoItems.count
        } else {
            return notDoneTodoItems.count
        }
    }
    
    func deleteTodoItem(by id: String) {
        // Удаление на листе(не в сети)
        self.items[id] = nil
        self.listVC?.updateTableView()
        
        service.deleteTodoItem(at: id) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let returnedItem):
                self.items[returnedItem.id] = nil
                self.listVC?.updateTableView()
            case .failure(_):
                print("not deleted")
            }
        }
    }
    
    func markAsDone(todoItem: TodoItem) {
        let markedAsDoneTodoItem = todoItem.asCompleted()
        editTodoItem(at: todoItem.id, to: markedAsDoneTodoItem)
    }
    
    func createTodoItem() {
        listVC?.presentToCreate(using: service)
    }
    
    func presentToEditTodoItem(at index: Int) {
        let todoItem = getTodoItems()[index]
        listVC?.presentToEdit(
            todoItem: todoItem,
            using: service
        )
    }
}

extension ListPresenter {
    
    func editTodoItem(at id: String, to todoItem: TodoItem) {
        service.editTodoItem(
            at: id,
            to: todoItem
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let returnedItem):
                self.items[id] = returnedItem
                self.listVC?.updateTableView()
            case .failure(_):
                print("not edited")
            }
        }
    }
    
    func addTodoItem(todoItem: TodoItem) {
        service.addTodoItem(todoItem) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let returnedItem):
                self.items[todoItem.id] = returnedItem
                self.listVC?.updateTableView()
            case .failure(_):
                print("not added")
            }
        }
    }
}
