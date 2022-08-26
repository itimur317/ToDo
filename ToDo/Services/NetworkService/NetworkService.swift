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
    case revisionNotMatched
    case notFound
    case serverError
}

final class DefaultNetworkService: NetworkService {
    
    private var revision: Int = 0
    private let baseURL: String = "https://beta.mrdekk.ru/todobackend"
    
    let timeout: Double = 2.0
    
    private let urlSession: URLSession
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private let token: String = "GuidebookOfDeadlyMemorials"
    
    private let isolationQueue = DispatchQueue(
        label: "NetworkServiceQueue",
        attributes: .concurrent
    )
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        urlSession = URLSession(configuration: config)
    }
    
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        isolationQueue.async(flags: .barrier) { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "GET"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)"
            ]
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                self.isolationQueue.sync(flags: .barrier) {
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                    
                    guard
                        let data = data,
                        let httpResponse = response as? HTTPURLResponse,
                        let listNetworkModel = try? self.jsonDecoder.decode(
                            ListNetworkModel.self,
                            from: data
                        ),
                        httpResponse.statusCode == 200
                    else {
                        DispatchQueue.main.async {
                            completion(.failure(NetworkServiceError.badFormedJson))
                        }
                        return
                    }
                    
                    if let newRevision = listNetworkModel.revision {
                        self.revision = newRevision
                    }
                    
                    let listTodoItems = listNetworkModel.list.map { $0.todoItem }
                    DispatchQueue.main.async {
                        completion(.success(listTodoItems))
                    }
                }
            }
            task.resume()
        }
    }
    
    func updateAllTodoItems(
        _ items: [TodoItem],
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        isolationQueue.async(flags: .barrier) { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "PATCH"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            // HTTP-Body
            let listNetworkModel = ListNetworkModel(
                list: items.map {
                    TodoItemNetworkModel(from: $0)
                }
            )
            
            do {
                urlRequest.httpBody = try self.jsonEncoder.encode(listNetworkModel)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let listNetworkModel = try? self.jsonDecoder.decode(
                        ListNetworkModel.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = listNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let listTodoItems = listNetworkModel.list.map { $0.todoItem }
                DispatchQueue.main.async {
                    completion(.success(listTodoItems))
                }
            }
            task.resume()
        }
    }
    
    func getTodoItem(
        by id: String,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        isolationQueue.async(flags: .barrier) { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list/\(id)") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "GET"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)"
            ]
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementNetworkModel.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = elementNetworkModel.element.todoItem
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
            }
            task.resume()
        }
    }
    
    func addTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        isolationQueue.async(flags: .barrier) { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "POST"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            // HTTP-Body
            let networkModel = TodoItemNetworkModel(from: item)
            let requestNetworkModel = ElementNetworkModel(element: networkModel)
            
            do {
                urlRequest.httpBody = try self.jsonEncoder.encode(requestNetworkModel)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementNetworkModel.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = elementNetworkModel.element.todoItem
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
                
            }
            task.resume()
        }
    }
    
    func editTodoItem(
        at id: String,
        to item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        isolationQueue.async(flags: .barrier) { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list/\(id)") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "PUT"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            // HTTP-Body
            let networkModel = TodoItemNetworkModel(from: item)
            let requestNetworkModel = ElementNetworkModel(element: networkModel)
            
            do {
                urlRequest.httpBody = try self.jsonEncoder.encode(requestNetworkModel)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementNetworkModel.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = elementNetworkModel.element.todoItem
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
            }
            task.resume()
        }
    }
    
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>
        ) -> Void) {
        isolationQueue.async(flags: .barrier) { [weak self] in
            guard
                let self = self,
                let url = URL(string: "\(self.baseURL)/list/\(id)") else {
                    return
                }
            
            // URL
            var urlRequest = URLRequest(url: url)
            
            // HTTP-Method
            urlRequest.httpMethod = "DELETE"
            
            // HTTP-Headers
            urlRequest.allHTTPHeaderFields = [
                "Authorization": "Bearer \(self.token)",
                "X-Last-Known-Revision": "\(self.revision)"
            ]
            
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
                guard
                    let data = data,
                    let httpResponse = response as? HTTPURLResponse,
                    let elementNetworkModel = try? self.jsonDecoder.decode(
                        ElementNetworkModel.self,
                        from: data
                    ),
                    httpResponse.statusCode == 200
                else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkServiceError.badFormedJson))
                    }
                    return
                }
                
                if let newRevision = elementNetworkModel.revision {
                    self.revision = newRevision
                }
                
                let todoItem = elementNetworkModel.element.todoItem
                DispatchQueue.main.async {
                    completion(.success(todoItem))
                }
            }
            task.resume()
        }
    }
}
