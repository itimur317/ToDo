//
//  CalendarCell.swift
//  ToDo
//
//  Created by Timur on 30.07.2022.
//

import UIKit

protocol DatePickerCellDelegate: AnyObject {
    func dateChanged(cell: DatePickerCell, date: Date)
}

final class DatePickerCell: UITableViewCell {
    
    weak var delegate: DatePickerCellDelegate?
    
    var deadline: Date {
        datePicker.date
    }
    
    private var height: CGFloat = 350

    private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.addTarget(
            self,
            action: #selector(dateChanged),
            for: .valueChanged
        )
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(width: CGFloat, date: Date) {
        height = width
        datePicker.date = date
        setConstraints()
    }
    
    private func setup() {
        backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        addSubview(datePicker)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    @objc
    private func dateChanged(_ sender: UIDatePicker) {
        delegate?.dateChanged(
            cell: self,
            date: datePicker.date
        )
    }
}
