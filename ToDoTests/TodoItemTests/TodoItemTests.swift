//
//  TodoItemTests.swift
//  ToDoTests
//
//  Created by Timur on 26.07.2022.
//

import XCTest
@testable import ToDo

class TodoItemTests: XCTestCase {
    
    var todoItem: TodoItem!
    
    override func tearDownWithError() throws {
        todoItem = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test struct TodoItem
    
    func testWithNilDeadlineAt() throws {
        // When
        todoItem = TodoItem(
            text: "text",
            importance: .basic,
            isDone: true,
            createdAt: .now
        )
        // Then
        XCTAssertNil(todoItem.deadlineAt)
    }
    
    func testWithNilChangedAt() throws {
        // When
        todoItem = TodoItem(
            text: "text",
            importance: .basic,
            isDone: true,
            createdAt: .now
        )
        // Then
        XCTAssertNil(todoItem.changedAt)
    }
    
    func testUUID() throws {
        // Given
        let todoItemAnotherId = TodoItem(
            text: "text",
            importance: .basic,
            isDone: true,
            createdAt: .now
        )
        
        // When
        todoItem = TodoItem(
            text: "text",
            importance: .basic,
            isDone: true,
            createdAt: .now
        )
        
        // Then
        XCTAssertNotEqual(
            todoItem.id,
            todoItemAnotherId.id
        )
    }
    
    // MARK: - Test TodoItem parse(json: Any)
    
    func testParseJsonWithAllProperty() throws {
        // Given
        let jsonString = makeJSON()
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(
            JSONSerialization.isValidJSONObject(json),
            "Invalid JSON"
        )
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertEqual(
            "testId",
            todoItem.id
        )
        XCTAssertEqual(
            "testText",
            todoItem.text
        )
        XCTAssertEqual(
            "low",
            todoItem.importance.rawValue
        )
        XCTAssertNotNil(todoItem.deadlineAt)
        XCTAssertEqual(
            1658797544,
            todoItem.deadlineAt?.timeIntervalSince1970
        )
        XCTAssertEqual(
            false,
            todoItem.isDone
        )
        XCTAssertEqual(
            1658797511,
            todoItem.createdAt.timeIntervalSince1970
        )
        XCTAssertNotNil(todoItem.changedAt)
        XCTAssertEqual(
            1658797533,
            todoItem.changedAt?.timeIntervalSince1970
        )
    }
    
    func testParseJsonWithoutId() throws {
        // Given
        let jsonString = """
        {
          "text": "testText",
          "importance": "low",
          "deadline": 1658797544,
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        
        XCTAssert(
            JSONSerialization.isValidJSONObject(json),
            "Invalid JSON"
        )
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    func testParseJsonWithoutText() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "importance": "low",
          "deadline": 1658797544,
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    func testParseJsonWithImportanceBasic() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "deadline": 1658797522,
          "done": false,
          "created_at": 1658797500,
          "changed_at": 1658797533
        }
        """
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertEqual(
            Importance.basic.rawValue,
            todoItem.importance.rawValue
        )
    }
    
    func testParseJsonWithoutDeadlineAt() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": "low",
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(
                with: jsonData,
                options: .fragmentsAllowed
              ),
              let todoItem = TodoItem.parse(json: json)
        else {
            return
        }
        
        // Then
        XCTAssertNotNil(jsonData)
        XCTAssertNotNil(json)
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        XCTAssertNotNil(todoItem)
        
        XCTAssertEqual(
            "testId",
            todoItem.id
        )
        XCTAssertEqual(
            "testText",
            todoItem.text
        )
        XCTAssertEqual(
            "low",
            todoItem.importance.rawValue
        )
        XCTAssertNil(todoItem.deadlineAt)
        XCTAssertEqual(
            false,
            todoItem.isDone
        )
        XCTAssertEqual(
            1658797511,
            todoItem.createdAt.timeIntervalSince1970
        )
        XCTAssertNotNil(todoItem.changedAt)
        XCTAssertEqual(
            1658797533,
            todoItem.changedAt?.timeIntervalSince1970
        )
    }
    
    func testParseJsonWithDeadlineToDate() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": "low",
          "deadline": 1658797544,
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertEqual(
            Date(timeIntervalSince1970: 1658797544),
            todoItem.deadlineAt
        )
    }
    
    func testParseJsonWithoutCreatedAt() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": "low",
          "deadline": 1658797544,
          "done": false,
          "changed_at": 1658797533
        }
        """
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    func testParseJsonWithoutChangedAt() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": "low",
          "deadline": 1658797544,
          "done": false,
          "created_at": 1658797511,
        }
        """
        
        // When
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        
        guard let json = try? JSONSerialization.jsonObject(
            with: jsonData,
            options: .fragmentsAllowed
        ) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertNotNil(jsonData)
        XCTAssertNotNil(json)
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        XCTAssertNotNil(todoItem)
        
        XCTAssertNil(todoItem.changedAt)
    }
    
    // MARK: - Test property json: Any
    
    func testGetJsonWithAllProperty() throws {
        // Given
        todoItem = TodoItem.fixture(
            id: "testId",
            text: "testText",
            importance: .low,
            deadlineAt: Date(timeIntervalSince1970: 1658923221),
            isDone: false,
            createdAt: Date(timeIntervalSince1970: 1658921520),
            changedAt: Date(timeIntervalSince1970: 1658923221)
        )
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(
            todoItem.id,
            parsedTodoItem.id
        )
        XCTAssertEqual(
            todoItem.text,
            parsedTodoItem.text
        )
        XCTAssertEqual(
            todoItem.importance,
            parsedTodoItem.importance
        )
        XCTAssertEqual(
            todoItem.deadlineAt,
            parsedTodoItem.deadlineAt
        )
        XCTAssertEqual(
            todoItem.isDone,
            parsedTodoItem.isDone
        )
        XCTAssertEqual(
            todoItem.createdAt,
            parsedTodoItem.createdAt
        )
        XCTAssertEqual(
            todoItem.changedAt,
            parsedTodoItem.changedAt
        )
    }
    
    func testGetJsonWithId() throws {
        // Given
        let todoItem = TodoItem.fixture(
            id: "testId",
            importance: .low
        )
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(parsedTodoItem.id, "testId")
    }
    
    func testGetJsonWithText() throws {
        // Given
        let todoItem = TodoItem.fixture(
            text: "testText",
            importance: .low
        )
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(parsedTodoItem.text, "testText")
    }
    
    func testGetJsonWithImportanceImportant() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .important)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(
            parsedTodoItem.importance.rawValue,
            "important"
        )
    }
    
    func testGetJsonWithImportanceBasic() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .basic)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(
            parsedTodoItem.importance.rawValue,
            "basic"
        )
    }
    
    func testGetJsonWithDeadlineAt() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .low)
        let json = todoItem.json
        
        // When
        guard let _ = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertNil(todoItem.deadlineAt)
    }
    
    func testGetJsonWithIsDone() throws {
        // Given
        let todoItem = TodoItem.fixture(
            importance: .basic,
            isDone: true
        )
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssert(parsedTodoItem.isDone)
    }
    
    func testGetJsonWithCreatedAt() throws {
        // Given
        let date = Date(timeIntervalSince1970: 1658954778)
        let todoItem = TodoItem.fixture(
            importance: .low,
            createdAt: date
        )
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(
            parsedTodoItem.createdAt,
            date
        )
    }
    
    func testGetJsonWithChangedAt() throws {
        // Given
        let date = Date(timeIntervalSince1970: 1658954778)
        let todoItem = TodoItem.fixture(
            importance: .low,
            changedAt: date
        )
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        
        // Then
        XCTAssertEqual(parsedTodoItem.changedAt, date)
    }
    
    private func makeJSON(
        id: String = "testId",
        text: String = "testText",
        importance: String = "low",
        deadline: Int = 1658797544,
        isDone: Bool = false,
        createdAt: Int = 1658797511,
        changedAt: Int = 1658797533
    ) -> String {
        return """
        {
          "id": "\(id)",
          "text": "\(text)",
          "importance": "\(importance)",
          "deadline": \(deadline),
          "done": \(isDone),
          "created_at": \(createdAt),
          "changed_at": \(changedAt)
        }
        """
    }
}

