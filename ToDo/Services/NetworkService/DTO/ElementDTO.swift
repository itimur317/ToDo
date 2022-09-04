//
//  ElementNetworkModel.swift
//  ToDo
//
//  Created by Timur on 18.08.2022.
//

struct ElementDTO: Codable {
    let status: String?
    let element: TodoItemDTO
    let revision: Int?
    
    enum CodingKeys: String, CodingKey {
        case status
        case element
        case revision
    }
    
    init(
        element: TodoItemDTO,
        status: String? = nil,
        revision: Int? = nil
    ) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
