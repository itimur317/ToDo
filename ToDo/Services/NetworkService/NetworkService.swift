//
//  NetworkService.swift
//  ToDo
//
//  Created by Timur on 12.08.2022.
//

import Foundation
import TodoItem

protocol NetworkService: AnyObject {
    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
    
    func updateAllTodoItems(
        _ items: [TodoItem],
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
    
    func getTodoItem(
        by: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    
    func addTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) 
}

enum NetworkServiceError: Error {
    case badFormedJson
    case authFailure
    case notFound
    case serverError
}

final class DefaultNetworkService: NetworkService {
    
    private var revision: Int = 0
    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
    
    private let urlSession = URLSession.shared
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    // TODO: - Закейнчейнить
    private let token: String = "GuidebookOfDeadlyMemorials"
    
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list") else {
            return
        }
        
        // URL
        var urlRequest = URLRequest(url: url)
        
        // HTTP-Method
        urlRequest.httpMethod = "GET"
        
        // HTTP-Headers
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)"
        ]
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                let listNetworkModel = try? self.jsonDecoder.decode(
                    ListNetworkModel.self,
                    from: data
                )
            else {
                return
            }
            
            if let newRevision = listNetworkModel.revision {
                self.revision = newRevision
            }
            
            print("revision -- \(self.revision)")
            print(httpResponse.statusCode)
            
            completion(.success(
                listNetworkModel.list.map { $0.todoItem }
            ))
        }
                
        task.resume()
    }
    
    func updateAllTodoItems(
        _ items: [TodoItem],
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        
        guard let url = URL(string: "\(baseURL)/list") else {
            return
        }
        
        // URL
        var urlRequest = URLRequest(url: url)
        
        // HTTP-Method
        urlRequest.httpMethod = "PATCH"
        
        // HTTP-Headers
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)",
            "X-Last-Known-Revision": "\(revision)"
        ]
        
        // HTTP-Body
        
        let listNetworkModel = ListNetworkModel(
            list: items.map {
                TodoItemNetworkModel(from: $0)
            }
        )
        
        do {
            urlRequest.httpBody = try jsonEncoder.encode(listNetworkModel)
            print("PATCHIM:", String(data: (try jsonEncoder.encode(listNetworkModel)), encoding: .utf8))
        } catch {
            completion(.failure(error))
        }
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                let listNetworkModel = try? self.jsonDecoder.decode(
                    ListNetworkModel.self,
                    from: data
                )
            else {
                return
            }
            
            if let newRevision = listNetworkModel.revision {
                self.revision = newRevision
            }
            
            print("revision -- \(self.revision)")
            print(httpResponse.statusCode)
            
            completion(.success(
                listNetworkModel.list.map { $0.todoItem }
            ))
        }
                
        task.resume()
    }
    
    func getTodoItem(
        by id: String,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/list/\(id)") else {
            return
        }
        
        // URL
        var urlRequest = URLRequest(url: url)
        
        // HTTP-Method
        urlRequest.httpMethod = "GET"
        
        // HTTP-Headers
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)"
        ]
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                let elementNetworkModel = try? self.jsonDecoder.decode(
                    ElementNetworkModel.self,
                    from: data
                )
            else {
                return
            }
            
            if let newRevision = elementNetworkModel.revision {
                self.revision = newRevision
            }
            
            print("revision -- \(self.revision)")
            print(httpResponse.statusCode)
            
            completion(.success(elementNetworkModel.element.todoItem))
        }
                
        task.resume()

    }
    
    func addTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/list") else {
            return
        }
        
        // URL
        var urlRequest = URLRequest(url: url)
        
        // HTTP-Method
        urlRequest.httpMethod = "POST"
        
        // HTTP-Headers
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)",
            "X-Last-Known-Revision": "\(revision)"
        ]
        
        // HTTP-Body
        let networkModel = TodoItemNetworkModel(from: item)
        let requestNetworkModel = ElementNetworkModel(element: networkModel)
        
        do {
            urlRequest.httpBody = try jsonEncoder.encode(requestNetworkModel)
            print("POLUCHIL", String(data: (try jsonEncoder.encode(requestNetworkModel)), encoding: .utf8))
        } catch {
            completion(.failure(error))
        }
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }

            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                let todoItemNetworkModel = try? self.jsonDecoder.decode(
                    ElementNetworkModel.self,
                    from: data
                )
            else {
                return
            }
            
            if let newRevision = todoItemNetworkModel.revision {
                self.revision = newRevision
            }
               
            print("revision -- \(self.revision)")
            print(httpResponse.statusCode)
            
            completion(.success(todoItemNetworkModel.element.todoItem))
        }

        task.resume()
    
    }
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/list/\(id)") else {
            return
        }
        
        // URL
        var urlRequest = URLRequest(url: url)
        
        // HTTP-Method
        urlRequest.httpMethod = "PUT"
        
        // HTTP-Headers
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)",
            "X-Last-Known-Revision": "\(revision)"
        ]
        
        // HTTP-Body
        let networkModel = TodoItemNetworkModel(from: item)
        let requestNetworkModel = ElementNetworkModel(element: networkModel)
        
        do {
            urlRequest.httpBody = try jsonEncoder.encode(requestNetworkModel)
            print("POLUCHIL", String(data: (try jsonEncoder.encode(requestNetworkModel)), encoding: .utf8))
        } catch {
            completion(.failure(error))
        }
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }

            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                let todoItemNetworkModel = try? self.jsonDecoder.decode(
                    ElementNetworkModel.self,
                    from: data
                )
            else {
                return
            }
            
            if let newRevision = todoItemNetworkModel.revision {
                self.revision = newRevision
            }
               
            print("revision -- \(self.revision)")
            print(httpResponse.statusCode)
            
            completion(.success(todoItemNetworkModel.element.todoItem))
        }

        task.resume()
        
    }

    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/list/\(id)") else {
            return
        }
        
        // URL
        var urlRequest = URLRequest(url: url)
        
        // HTTP-Method
        urlRequest.httpMethod = "DELETE"
        
        // HTTP-Headers
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)",
            "X-Last-Known-Revision": "\(revision)"
        ]
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                let elementNetworkModel = try? self.jsonDecoder.decode(
                    ElementNetworkModel.self,
                    from: data
                )
            else {
                return
            }
            
            if let newRevision = elementNetworkModel.revision {
                self.revision = newRevision
            }
            
            print("revision -- \(self.revision)")
            print(httpResponse.statusCode)
            
            completion(.success(elementNetworkModel.element.todoItem))
        }
                
        task.resume()

    }
    
 }
