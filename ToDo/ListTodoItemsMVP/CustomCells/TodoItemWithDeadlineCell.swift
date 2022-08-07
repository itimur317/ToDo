//
//  TodoItemWithDeadlineCell.swift
//  ToDo
//
//  Created by Timur on 05.08.2022.
//

import UIKit

final class TodoItemWithDeadlineCell: UITableViewCell {
    
    private var doneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        return imageView
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        label.textColor = UIColor(named: "cellText")
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "littleCalendar")
        imageView.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.attributedText = .none
    }
    
    func configure(todoItem: TodoItem) {
        switch todoItem.importance {
        case .low:
            descriptionLabel.text = todoItem.text
        case .basic:
            descriptionLabel.text = todoItem.text
        case .important:
            descriptionLabel.text = "‼️" + todoItem.text
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        deadlineLabel.text = dateFormatter.string(from: todoItem.deadlineAt!)
        
        if todoItem.isDone {
            let config = UIImage.SymbolConfiguration(
                font: .boldSystemFont(ofSize: 20),
                scale: .large
            )
            doneImageView.image = UIImage(
                systemName: "checkmark.circle.fill",
                withConfiguration: config
            )
            doneImageView.tintColor = .green
            
            descriptionLabel.attributedText = NSAttributedString(
                string: descriptionLabel.text ?? " ",
                attributes: [
                    NSAttributedString.Key.strikethroughStyle:
                        NSUnderlineStyle.single.rawValue
                ]
            )
        } else {
            let config = UIImage.SymbolConfiguration(
                font: .boldSystemFont(ofSize: 20),
                scale: .large
            )
            doneImageView.image = UIImage(
                systemName: "circle",
                withConfiguration: config
            )
            if let deadline = todoItem.deadlineAt, deadline < Date(){
                doneImageView.tintColor = .red
            } else {
                doneImageView.tintColor = .lightGray
            }
        }
    }
    
    private func setup() {
        backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        addSubview(doneImageView)
        addSubview(descriptionLabel)
        addSubview(calendarImageView)
        addSubview(deadlineLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            doneImageView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 10
            ),
            doneImageView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 5
            ),
            doneImageView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -10
            ),
            doneImageView.widthAnchor.constraint(
                equalToConstant: 40
            )
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(
                equalTo: doneImageView.trailingAnchor,
                constant: 10
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -30
            ),
            descriptionLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 15
            )
        ])
        
        NSLayoutConstraint.activate([
            calendarImageView.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: 5
            ),
            calendarImageView.leadingAnchor.constraint(
                equalTo: doneImageView.trailingAnchor,
                constant: 10
            ),
            calendarImageView.widthAnchor.constraint(
                equalToConstant: 15
            ),
            calendarImageView.heightAnchor.constraint(
                equalToConstant: 15
            ),
            calendarImageView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -15
            )
        ])
        
        NSLayoutConstraint.activate([
            deadlineLabel.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: 5
            ),
            deadlineLabel.leadingAnchor.constraint(
                equalTo: calendarImageView.trailingAnchor,
                constant: 2
            ),
            deadlineLabel.heightAnchor.constraint(
                equalToConstant: 15
            ),
            deadlineLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -15
            )
        ])
    }
}

