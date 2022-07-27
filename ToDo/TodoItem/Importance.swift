//
//  Importance.swift
//  ToDo
//
//  Created by Timur on 27.07.2022.
//

import Foundation


enum Importance: String {
    case low, basic, important
}

extension Importance {
    func isBasic() -> Bool {
        switch self {
        case .basic:
            return true
        default:
            return false
        }
    }
}
