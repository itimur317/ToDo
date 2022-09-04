//
//  ElementNetworkModel.swift
//  ToDo
//
//  Created by Timur on 18.08.2022.
//

struct ElementNetworkModel: Codable {
    let status: String?
    let element: TodoItemNetworkModel
    let revision: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case element
        case revision
    }
    
    init(
        element: TodoItemNetworkModel,
        status: String? = nil,
        revision: Int? = nil
    ) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
