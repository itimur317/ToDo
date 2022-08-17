//
//  Date+Extension.swift
//  ToDo
//
//  Created by Timur on 06.08.2022.
//

import Foundation

// MARK: - Date next day

extension Date {
    static var nextDay: Date {
        let secondsPerDay: TimeInterval = 86_400
        return Date().addingTimeInterval(secondsPerDay)
    }
}
