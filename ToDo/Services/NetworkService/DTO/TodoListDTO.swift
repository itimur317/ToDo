//
//  ListNetworkModel.swift
//  ToDo
//
//  Created by Timur on 18.08.2022.
//

struct TodoListDTO: Codable {
    let status: String?
    let list: [TodoItemDTO]
    let revision: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case list
        case revision
    }
    
    init(
        list: [TodoItemDTO],
        status: String? = nil,
        revision: Int? = nil
    ) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}
