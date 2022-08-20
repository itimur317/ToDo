//
//  ListTodoItemsVC.swift
//  ToDo
//
//  Created by Timur on 03.08.2022.
//

import UIKit
import TodoItem
import CocoaLumberjack

protocol ListTodoItemsVCProtocol: AnyObject {
    func updateShowHideLabel()
    func updateTableView()
    
    func setDoneLabel(amount: Int)
    func alertWith(text: String)
    
    func presentToEdit(todoItem: TodoItem, using: Service)
    func presentToCreate(using: Service)
}

final class ListTodoItemsVC: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             ListTodoItemsVCProtocol {
    
    private let presenter: ListTodoItemsPresenterProtocol
    
    init(presenter: ListTodoItemsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        DDLogError("Здесь могла быть ваша ошибка")
        fatalError("init(coder:) has not been implemented")
    }
    
    private let doneLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "listBackground")
        label.textColor = .lightGray
        label.text = "Выполнено — 0"
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var showHideButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "listBackground")
        button.setTitleColor(
            UIColor(named: "blue"),
            for: .normal
        )
        button.setTitle("Скрыть", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(
            self,
            action: #selector(didTapShowHideButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let listTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        tableView.register(
            TodoItemWithoutDeadlineCell.self,
            forCellReuseIdentifier: "TodoItemWithoutDeadlineCell"
        )
        tableView.register(
            TodoItemWithDeadlineCell.self,
            forCellReuseIdentifier: "TodoItemWithDeadlineCell"
        )
        tableView.register(
            NewTodoItemCell.self,
            forCellReuseIdentifier: "NewTodoItemCell"
        )
        tableView.layer.cornerRadius = 20
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    
    private lazy var addTodoItemButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "listBackground")
        let config = UIImage.SymbolConfiguration(
            font: UIFont.boldSystemFont(ofSize: 40),
            scale: .large
        )
        button.setImage(
            UIImage(systemName: "plus.circle.fill",
                    withConfiguration: config
                   ),
            for: .normal
        )
        button.tintColor = UIColor(named: "blue")
        button.addTarget(
            self,
            action: #selector(didTapAddTodoItemButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        tableHeightConstraint?.constant = listTableView.contentSize.height
    }
    
    private func setup() {
        setEnvironment()
        addSubviews()
        setDelegate()
        setConstraints()
        updateTableView()
    }
    
    private func setEnvironment() {
        view.backgroundColor = UIColor(named: "listBackground")
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func addSubviews() {
        view.addSubview(doneLabel)
        view.addSubview(showHideButton)
        view.addSubview(listTableView)
        view.addSubview(addTodoItemButton)
    }
    
    private func setDelegate() {
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            doneLabel.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 10
            ),
            doneLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 15
            ),
            doneLabel.heightAnchor.constraint(
                equalToConstant: 15
            )
        ])
        
        NSLayoutConstraint.activate([
            showHideButton.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 10
            ),
            showHideButton.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -15
            ),
            showHideButton.heightAnchor.constraint(
                equalToConstant: 15
            )
        ])
        
        NSLayoutConstraint.activate([
            addTodoItemButton.widthAnchor.constraint(
                equalToConstant: 65
            ),
            addTodoItemButton.heightAnchor.constraint(
                equalToConstant: 65
            ),
            addTodoItemButton.centerXAnchor.constraint(
                equalTo: safeArea.centerXAnchor
            ),
            addTodoItemButton.bottomAnchor.constraint(
                equalTo: safeArea.bottomAnchor,
                constant: -20
            )
        ])
        
        tableHeightConstraint = listTableView.heightAnchor.constraint(equalToConstant: 2000)
        
        guard let heightConstraint = tableHeightConstraint else {
            return
        }
        
        NSLayoutConstraint.activate([
            listTableView.topAnchor.constraint(
                equalTo: doneLabel.bottomAnchor,
                constant: 10
            ),
            listTableView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 20
            ),
            listTableView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -20
            ),
            heightConstraint,
            listTableView.bottomAnchor.constraint(
                lessThanOrEqualTo: addTodoItemButton.topAnchor,
                constant: -20
            )
        ])
    }
    
    @objc
    private func didTapShowHideButton(_: UIButton) {
        presenter.showHideDoneTodoItems()
    }
    
    @objc
    private func didTapAddTodoItemButton(_: UIButton) {
        presenter.createTodoItem()
    }
}

// MARK: - UITableViewDelegate

extension ListTodoItemsVC {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case presenter.getTodoItemsCount():
            presenter.createTodoItem()
        default:
            presenter.editTodoItem(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        if indexPath.row == presenter.getTodoItemsCount() {
            return nil
        }
        let todoItem = presenter.getTodoItems()[indexPath.row]
        
        if todoItem.isDone {
            return nil
        }
        
        let markAsDoneButton = UIContextualAction(style: .normal, title: "") { [weak self] (_, _, completion) in
            self?.presenter.markAsDone(todoItem: todoItem)
            completion(true)
        }
        let configMarkAsDone = UIImage.SymbolConfiguration(
            font: .boldSystemFont(ofSize: 20),
            scale: .large
        )
        markAsDoneButton.image = UIImage(
            systemName: "checkmark.circle.fill",
            withConfiguration: configMarkAsDone
        )
        markAsDoneButton.backgroundColor = .green
        
        let config = UISwipeActionsConfiguration(actions: [markAsDoneButton])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        if indexPath.row == presenter.getTodoItemsCount() {
            return nil
        }
        let todoItem = presenter.getTodoItems()[indexPath.row]
        
        // Delete button settings
        let deleteButton = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completion) in
            self?.presenter.deleteTodoItem(by: todoItem)
            completion(true)
        }
        let configDelete = UIImage.SymbolConfiguration(
            font: .boldSystemFont(ofSize: 20),
            scale: .large
        )
        deleteButton.image = UIImage(
            systemName: "trash.fill",
            withConfiguration: configDelete
        )
        deleteButton.backgroundColor = .red
        
        // Info button settings
        let infoButton = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completion) in
            self?.presenter.editTodoItem(at: indexPath.row)
            completion(true)
        }
        let configInfo = UIImage.SymbolConfiguration(
            font: .boldSystemFont(ofSize: 20),
            scale: .large
        )
        infoButton.image = UIImage(
            systemName: "info.circle.fill",
            withConfiguration: configInfo
        )
        infoButton.backgroundColor = .lightGray
        
        let config = UISwipeActionsConfiguration(actions: [deleteButton, infoButton])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

// MARK: - UITableViewDataSource

extension ListTodoItemsVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getTodoItemsCount() + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            
        case presenter.getTodoItemsCount():
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "NewTodoItemCell"
            ) as? NewTodoItemCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
            
        default:
            if presenter.getTodoItems()[indexPath.row].deadlineAt != nil {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TodoItemWithDeadlineCell"
                ) as? TodoItemWithDeadlineCell else {
                    return UITableViewCell()
                }
                cell.configure(todoItem: presenter.getTodoItems()[indexPath.row])
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TodoItemWithoutDeadlineCell"
                ) as? TodoItemWithoutDeadlineCell else {
                    return UITableViewCell()
                }
                cell.configure(todoItem: presenter.getTodoItems()[indexPath.row])
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.selectionStyle = .none
                return cell
            }
        }
    }
}

// MARK: - ListTodoItemsVCProtocol

extension ListTodoItemsVC {
    func updateShowHideLabel() {
        if showHideButton.titleLabel?.text == "Показать" {
            showHideButton.setTitle("Скрыть", for: .normal)
        } else {
            showHideButton.setTitle("Показать", for: .normal)
        }
    }
    
    func updateTableView() {
        listTableView.reloadData()
        listTableView.setNeedsLayout()
        listTableView.layoutIfNeeded()
    }
    
    func setDoneLabel(amount: Int) {
        doneLabel.text = "Выполнено — \(amount)"
    }
    
    func alertWith(text: String) {
        let alert = UIAlertController(
            title: text,
            message: "Произошла ошибка",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Ок",
            style: .default,
            handler: nil
        ))
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    func presentToEdit(todoItem: TodoItem, using storage: Service) {
        let todoItemPresenter = TodoItemPresenter(to: .edit(todoItem: todoItem), using: storage)
        let todoItemVC = TodoItemVC(presenter: todoItemPresenter)
        todoItemPresenter.todoItemVC = todoItemVC
        
        let nav = UINavigationController(rootViewController: todoItemVC)
        todoItemVC.isDismissed = { [weak self] in
            self?.presenter.viewDidLoad()
        }
        self.present(nav, animated: true, completion: nil)
    }
    
    func presentToCreate(using storage: Service) {
        let todoItemPresenter = TodoItemPresenter(to: .createNew, using: storage)
        let todoItemVC = TodoItemVC(presenter: todoItemPresenter)
        todoItemPresenter.todoItemVC = todoItemVC
        
        let nav = UINavigationController(rootViewController: todoItemVC)
        todoItemVC.isDismissed = { [weak self] in
            self?.presenter.viewDidLoad()
        }
        self.present(nav, animated: true, completion: nil)
    }
}
