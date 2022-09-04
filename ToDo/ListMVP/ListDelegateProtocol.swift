//
//  ListPresenterProtocol.swift
//  ToDo
//
//  Created by Timur on 21.08.2022.
//

import TodoItem

protocol ListDelegateProtocol: AnyObject {
    func deleteTodoItem(by: String)
    func editTodoItem(at: String, to: TodoItem)
    func addTodoItem(todoItem: TodoItem)
}

protocol ListPresenterProtocol: ListDelegateProtocol {
    func viewDidLoad()
    
    func showHideDoneTodoItems()
    
    func getTodoItems() -> [TodoItem]
    func getTodoItemsCount() -> Int
    
    func markAsDone(todoItem: TodoItem)
    
    func createTodoItem()
    func presentToEditTodoItem(at: Int)
}
