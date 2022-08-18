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
    
    private let fileCache = FileCache()
    
    private let dir: String = "Main"
    
    private let networkService = DefaultNetworkService()
    
    func viewDidLoad() {
        let item = TodoItem(
            text: "otpuskayu i v nebo",
            importance: .low,
            isDone: false,
            createdAt: Date(),
            id: "izi3000",
            deadlineAt: Date(),
            changedAt: Date()
        )
        
//        networkService.addTodoItem(item) { result in
//            switch result {
//            case .success(let item):
//                print("DOBAVIL \(item)")
//            case .failure(let error):
//                print("OSHIBOcHKA \(error)")
//            }
//        }
        
//        networkService.getTodoItem(by: "hqd") { result in
//            switch result {
//            case .success(let todoItem):
//                print("ZAGRUZIL ODIN \(todoItem)")
//            case .failure(let error):
//                print("OSHIBOcHKA \(error)")
//            }
//        }
        
//        networkService.deleteTodoItem(at: "izi3") { result in
//            switch result {
//            case .success(let todoItem):
//                print("UDALIL \(todoItem)")
//            case .failure(let error):
//                print("OSHIBOcHKA \(error)")
//            }
//        }
//
//        networkService.editTodoItem(at: "izi3", to: item) { result in
//            switch result {
//            case .success(let todoItem):
//                print("ZAMENIL \(todoItem)")
//            case .failure(let error):
//                print("OSHIBOcHKA \(error)")
//            }
//        }
        
        networkService.getAllTodoItems { result in
            switch result {
            case .success(let todoItems):
                print("ZAGRUZIL \(todoItems)")

            case .failure(let error):
                print("OSHIBOcHKA \(error)")
            }
        }
        
        let item1 = TodoItem(
            text: "koncert maxim",
            importance: .basic,
            isDone: true,
            createdAt: Date(),
            id: "chapman3",
            deadlineAt: Date(),
            changedAt: Date()
        )
        
        let item2 = TodoItem(
            text: "koncert maxim",
            importance: .basic,
            isDone: true,
            createdAt: Date(),
            id: "chapman4",
            deadlineAt: Date(),
            changedAt: Date()
        )
        
        self.networkService.updateAllTodoItems([item1, item2]) { result in
            switch result {
            case .success(let todoItems):
                print("ZAPATCHIL \(todoItems)")
            case .failure(let error):
                print("OSHIBOcHKA \(error)")
            }
        }
        
        do {
            try fileCache.load(from: dir)
        } catch {
            // Протестировал, тут всё ок
            // просто вернется пустая коллекция
            
            // Как правильно обрабатывать функции с ошибками,
            // если даже при выбрасывании ошибки всё ок отрабатывает?
            print(fileCache.items)
        }
        listTodoItemsVC?.updateTableView()
    }
    
    private var allTodoItems: [TodoItem] {
        fileCache.items.values.sorted { todoItem1, todoItem2 in
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
        
        do {
            try fileCache.delete(id: id)
            listTodoItemsVC?.updateTableView()
            DispatchQueue.global().async { [weak self] in
                guard
                    let dir = self?.dir,
                    (try? self?.fileCache.clearCache(by: dir)) != nil,
                    (try? self?.fileCache.save(to: dir)) != nil
                else {
                    return
                }
            }
        } catch {
            listTodoItemsVC?.alertWith(text: "Удалить не получилось!")
        }
    }
    
    func markAsDone(todoItem: TodoItem) {
        let markedAsDoneTodoItem = TodoItem(
            text: todoItem.text,
            importance: todoItem.importance,
            isDone: true,
            createdAt: todoItem.createdAt,
            deadlineAt: todoItem.deadlineAt,
            changedAt: todoItem.changedAt
        )
        
        do {
            try fileCache.delete(id: todoItem.id)
            try fileCache.add(todoItem: markedAsDoneTodoItem)
            
            DispatchQueue.global().async { [weak self] in
                guard
                    let dir = self?.dir,
                    (try? self?.fileCache.clearCache(by: dir)) != nil,
                    (try? self?.fileCache.save(to: dir)) != nil
                else {
                    return
                }
            }
        } catch {
            return
        }
        
        listTodoItemsVC?.updateTableView()
    }
    
    func createTodoItem() {
        listTodoItemsVC?.presentToCreate(in: dir)
    }
    
    func editTodoItem(at index: Int) {
        let todoItem = getTodoItems()[index]
        listTodoItemsVC?.presentToEdit(todoItem: todoItem, in: dir)
    }
}
