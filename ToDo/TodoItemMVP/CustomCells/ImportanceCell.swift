//
//  ImportanceCell.swift
//  ToDo
//
//  Created by Timur on 29.07.2022.
//

import UIKit

protocol ImportanceCellDelegate: AnyObject {
    func importanceChanged(cell: ImportanceCell, importance: Importance)
}

final class ImportanceCell: UITableViewCell {
    
    weak var delegate: ImportanceCellDelegate?
    
    private var importance: Importance {
        switch importanceSegmentedControl.selectedSegmentIndex {
        case 0:
            return .low
        case 2:
            return .important
        default:
            return .basic
        }
    }
    
    private var cellHeight: CGFloat = 50
    
    private var importanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Важность"
        label.textColor = UIColor(named: "cellText")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var importanceSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["", "нет", ""])
        segmentedControl.backgroundColor = UIColor(named: "segmentedControlBackground")
        segmentedControl.setImage(
            UIImage(named: "low"),
            forSegmentAt: 0
        )
        segmentedControl.setImage(
            UIImage(named: "important"),
            forSegmentAt: 2
        )
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(
            self,
            action: #selector(didValueChanged),
            for: .valueChanged
        )
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        height: CGFloat,
        importance: Importance
    ) {
        switch importance {
        case .low :
            importanceSegmentedControl.selectedSegmentIndex = 0
        case .basic:
            importanceSegmentedControl.selectedSegmentIndex = 1
        case .important:
            importanceSegmentedControl.selectedSegmentIndex = 2
        }
        cellHeight = height
    }
    
    private func setup() {
        backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        addSubview(importanceLabel)
        addSubview(importanceSegmentedControl)
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            importanceLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 20
            ),
            importanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            importanceLabel.widthAnchor.constraint(equalToConstant: cellHeight * 2),
            importanceLabel.heightAnchor.constraint(equalToConstant: cellHeight / 2)
        ])
        
        NSLayoutConstraint.activate([
            importanceSegmentedControl.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -20
            ),
            importanceSegmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            importanceSegmentedControl.widthAnchor.constraint(equalToConstant: cellHeight * 2.4),
            importanceSegmentedControl.heightAnchor.constraint(equalToConstant: cellHeight / 2)
        ])
    }
    
    @objc
    private func didValueChanged(_ sender: UISegmentedControl) {
        delegate?.importanceChanged(
            cell: self,
            importance: importance
        )
    }
}
