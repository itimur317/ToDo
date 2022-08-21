//
//  ListNetworkModel.swift
//  ToDo
//
//  Created by Timur on 18.08.2022.
//

struct ListNetworkModel: Codable {
    let status: String?
    let list: [TodoItemNetworkModel]
    let revision: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case list
        case revision
    }
    
    init(
        list: [TodoItemNetworkModel],
        status: String? = nil,
        revision: Int? = nil
    ) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}
