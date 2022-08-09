//
//  DeadlineCell.swift
//  ToDo
//
//  Created by Timur on 29.07.2022.
//

import UIKit

protocol DeadlineCellDelegate: AnyObject {
    func saveDeadline(cell: DeadlineCell, willSave: Bool)
    func showDatePicker(cell: DeadlineCell)
}

final class DeadlineCell: UITableViewCell {
    
    weak var delegate: DeadlineCellDelegate?
    
    private var willSave: Bool = false
    
    private var deadlineLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Сделать до"
        label.textColor = UIColor(named: "cellText")
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = UIColor(named: "blue")
        return label
    }()
    
    private lazy var deadlineSwitch: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.addTarget(
            self,
            action: #selector(didValueChanged),
            for: .valueChanged
        )
        deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
        return deadlineSwitch
        
    }()
    
    private var cellHeight: CGFloat = 50

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(height: CGFloat, deadline: Date, willSave: Bool) {
        self.willSave = willSave
        deadlineSwitch.setOn(
            willSave,
            animated: true
        )
        setLabelsFrame()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY"
        dateLabel.text = dateFormatter.string(from: deadline)
        cellHeight = height
    }
    
    private func setup() {
        backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        addSubview(deadlineLabel)
        addSubview(dateLabel)
        addSubview(deadlineSwitch)
        setLabelsFrame()
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            deadlineSwitch.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -20
            ),
            deadlineSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            deadlineSwitch.widthAnchor.constraint(equalToConstant: cellHeight),
            deadlineSwitch.heightAnchor.constraint(equalToConstant: cellHeight / 2)
        ])
    }

    private func setLabelsFrame() {
        dateLabel.frame = CGRect(
            x: 20,
            y: cellHeight * 5 / 10,
            width: cellHeight * 3,
            height: cellHeight * 3 / 10
        )
        
        if willSave {
            deadlineLabel.frame = CGRect(
                x: 20,
                y: cellHeight / 10,
                width: cellHeight * 2,
                height: cellHeight / 3
            )
            dateLabel.isHidden = false
        } else {
            deadlineLabel.frame = CGRect(
                x: 20,
                y: cellHeight / 5,
                width: cellHeight * 2,
                height: cellHeight * 3 / 5
            )
            dateLabel.isHidden = true
        }
    }
    
    @objc
    private func didValueChanged(_ sender: UISwitch) {
        willSave = sender.isOn
        setLabelsFrame()
        delegate?.saveDeadline(
            cell: self,
            willSave: willSave
        )
        delegate?.showDatePicker(cell: self)
    }
}
