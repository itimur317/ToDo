//
//  TodoItemVC.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import UIKit

protocol TodoItemVCProtocol: AnyObject {
    func getDescriptionText() -> String?
    
    func failureSaveTodoItem()
    func successSaveTodoItem()
    
    func failureDeleteTodoItem()
    func successDeleteTodoItem()
    
    func dismiss()
}

final class TodoItemVC: UIViewController,
                        TodoItemVCProtocol,
                        UITextViewDelegate,
                        UITableViewDelegate,
                        ImportanceCellDelegate,
                        DeadlineCellDelegate,
                        DatePickerCellDelegate,
                        UITableViewDataSource {
    
    var isDismissed: (() -> Void)?
    
    private let presenter: TodoItemPresenterProtocol
    
    init(presenter: TodoItemPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(named: "addTodoItemBackground")
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "addTodoItemBackground")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.text = "Что надо сделать?"
        textView.textColor = UIColor.lightGray
        textView.tintColor = UIColor(named: "cellText")
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 20
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var minDescriptionTextViewHeight: CGFloat = 120
    
    private let impAndDeadlinTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(
            ImportanceCell.self,
            forCellReuseIdentifier: "Importance"
        )
        tableView.register(
            DeadlineCell.self,
            forCellReuseIdentifier: "Deadline"
        )
        tableView.register(
            DatePickerCell.self,
            forCellReuseIdentifier: "DatePicker"
        )
        tableView.layer.cornerRadius = 20
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var cellAmount = 2
    private let cellHeight: CGFloat = 50
    private var tableWidth: CGFloat = 320
    
    private var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "cellsAddTodoItemBackground")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(
            self,
            action: #selector(didTapDeleteButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var keyboardIndent: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isDismissed?()
    }
    
    private func setup() {
        setKeyboardSettings()
        setDescriptionText()
        setEnvironment()
        setTableWidth()
        addSubviews()
        setDelegates()
        textViewDidChange(descriptionTextView)
        setConstraints()
    }
    
    private func setKeyboardSettings() {
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setDescriptionText() {
        if let text = presenter.getText() {
            descriptionTextView.text = text
            descriptionTextView.textColor = UIColor(named: "cellText")
        }
    }
    
    private func setEnvironment() {
        title = "Дело"
        view.backgroundColor = UIColor(named: "addTodoItemBackground")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(didTapSaveButton)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(didTapCancelButton)
        )
    }
    
    private func setTableWidth() {
        tableWidth = view.frame.width < view.frame.height ? view.frame.width : view.frame.height
        tableWidth -= 40
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(impAndDeadlinTableView)
        scrollView.addSubview(deleteButton)
    }
    
    private func setDelegates() {
        descriptionTextView.delegate = self
        impAndDeadlinTableView.delegate = self
        impAndDeadlinTableView.dataSource = self
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
        
        let contentScrollView = scrollView.contentLayoutGuide
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
        ])
        
        let contentViewCenterY = contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)

        let contentViewCenterX = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)

        contentViewCenterX.priority = .defaultLow
        contentViewCenterY.priority = .defaultLow

        let contentViewWidth = contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        let contentViewHeight = contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        contentViewHeight.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            contentViewCenterX,
            contentViewCenterY,
            contentViewWidth,
            contentViewHeight
        ])
        
        NSLayoutConstraint.activate([
            descriptionTextView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            descriptionTextView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            descriptionTextView.heightAnchor.constraint(equalToConstant: minDescriptionTextViewHeight),
            descriptionTextView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 20
            )
        ])

        NSLayoutConstraint.activate([
            impAndDeadlinTableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            impAndDeadlinTableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            impAndDeadlinTableView.topAnchor.constraint(
                equalTo: descriptionTextView.bottomAnchor,
                constant: 20
            )
        ])
        
        if presenter.getWillSaveDeadline() {
            cellAmount = 3
            impAndDeadlinTableView.heightAnchor.constraint(equalToConstant: cellHeight * 2 + tableWidth).isActive = true
        } else {
            cellAmount = 2
            impAndDeadlinTableView.heightAnchor.constraint(equalToConstant: cellHeight * 2).isActive = true
        }
        
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            deleteButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            deleteButton.heightAnchor.constraint(equalToConstant: cellHeight),
            deleteButton.topAnchor.constraint(
                equalTo: impAndDeadlinTableView.bottomAnchor,
                constant: 20),
            deleteButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -20
            )
        ])
    }
    
    private func updateTableView() {
        cellAmount = cellAmount == 3 ? 2 : 3
        
        impAndDeadlinTableView.setNeedsUpdateConstraints()
        impAndDeadlinTableView.updateConstraints()
        impAndDeadlinTableView.reloadData()

        impAndDeadlinTableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = constraint.constant == cellHeight * 2 ?
                cellHeight * 2 + tableWidth : cellHeight * 2
                impAndDeadlinTableView.reloadRows(
                    at: [IndexPath(row: 2, section: 0 )],
                    with: .none
                )
            }
        }
    }
    
    @objc
    private func didTapSaveButton(_: UIButton) {
        presenter.saveTodoItem()
    }
    
    @objc
    private func didTapDeleteButton(_: UIButton) {
        presenter.deleteTodoItem()
    }
    
    @objc
    private func didTapCancelButton(_: UIButton) {
        presenter.cancelEdit()
    }
}

// MARK: - UITextViewDelegate

extension TodoItemVC {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(
            width: tableWidth,
            height: .infinity
        )
        let estimatedSize = descriptionTextView.sizeThatFits(size)
        
        descriptionTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height > minDescriptionTextViewHeight ?
                estimatedSize.height : minDescriptionTextViewHeight
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "cellText")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.lightGray
        }
    }
}

// MARK: - UITableViewDataSource

extension TodoItemVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "Importance",
                for: indexPath
            ) as? ImportanceCell else {
                return UITableViewCell()
            }
            cell.configure(
                height: cellHeight,
                importance: presenter.getImportance() ?? .basic
            )
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "Deadline",
                for: indexPath
            ) as? DeadlineCell else {
                return UITableViewCell()
            }
            cell.configure(
                height: cellHeight,
                deadline: presenter.getDeadline() ?? Date.nextDay,
                willSave: presenter.getWillSaveDeadline()
            )
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DatePicker",
                for: indexPath
            ) as? DatePickerCell else {
                return UITableViewCell()
            }
            cell.configure(
                width: tableWidth,
                date: presenter.getDeadline() ?? .nextDay
            )
            presenter.setDeadline(cell.deadline)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        default:
           return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension TodoItemVC {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return tableWidth
        default:
            return cellHeight
        }
    }
}

// MARK: - ImportanceCellDelegate

extension TodoItemVC {
    func importanceChanged(
        cell: ImportanceCell,
        importance: Importance
    ) {
        presenter.setImportance(importance)
    }
}

// MARK: - DeadlineCellDelegate

extension TodoItemVC {
    func saveDeadline(
        cell: DeadlineCell,
        willSave: Bool
    ) {
        presenter.setWillSaveDeadline(willSave)
    }
    
    func showDatePicker(cell: DeadlineCell) {
        updateTableView()
    }
}

// MARK: - DatePickerCellDelegate

extension TodoItemVC {
    func dateChanged(
        cell: DatePickerCell,
        date: Date
    ) {
        presenter.setDeadline(date)
        impAndDeadlinTableView.reloadData()
    }
}

// MARK: - TodoItemVCProtocol

extension TodoItemVC {
    func getDescriptionText() -> String? {
        if !descriptionTextView.text.isEmpty && descriptionTextView.textColor != UIColor.lightGray {
            return descriptionTextView.text
        }
        return nil
    }
    
    func failureSaveTodoItem() {
        let alert = UIAlertController(
            title: "Ошибка!",
            message: "Произошла ошибка\nНе получилось сохранить дело",
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
    
    func successSaveTodoItem() {
        let alert = UIAlertController(
            title: "Успех!",
            message: "Дело сохранено",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Ок",
            style: .default,
            handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }
        ))
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    func failureDeleteTodoItem() {
        let alert = UIAlertController(
            title: "Ошибка!",
            message: "Произошла ошибка\nНе получилось удалить дело",
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
    
    func successDeleteTodoItem() {
        let alert = UIAlertController(
            title: "Успех!",
            message: "Дело удалено",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Ок",
            style: .default,
            handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }
        ))
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Keyboard settings

extension TodoItemVC {
    // скопирован с https://fluffy.es/move-view-when-keyboard-is-shown/
    // протестирован
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardSize.height ,
            right: 0.0
        )
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
