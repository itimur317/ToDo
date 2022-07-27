//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Timur on 26.07.2022.
//

import XCTest
@testable import ToDo


class ImportanceTests: XCTestCase {

    var importance: Importance!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        importance = nil
        try super.tearDownWithError()
    }

    
    // MARK: - test isBasic
    
    func testImportanceIsBasicWithLow() throws {
        // When
        importance = .low
        // Then
        XCTAssert(!importance.isBasic())
    }
    
    func testImportanceIsBasicWithBasic() throws {
        // When
        importance = .basic
        // Then
        XCTAssert(importance.isBasic())
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}


class TodoItemTests: XCTestCase {
    
    var todoItem: TodoItem!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        todoItem = nil
        try super.tearDownWithError()
    }

    
    // MARK: - test struct TodoItem
    
    func testTodoItemWithNilDeadlineAt() throws {
        // When
        todoItem = TodoItem(text: "text", importance: .basic,
                            isDone: true, createdAt: .now)
        // Then
        XCTAssertNil(todoItem.deadlineAt)
    }
    
    
    func testTodoItemWithNilChangedAt() throws {
        // When
        todoItem = TodoItem(text: "text", importance: .basic,
                            isDone: true, createdAt: .now)
        // Then
        XCTAssertNil(todoItem.changedAt)
    }
    
    
    func testTodoItemUUID() throws {
        // Given
        let todoItemAnotherId = TodoItem(text: "text", importance: .basic,
                                         isDone: true, createdAt: .now)
        
        // When
        todoItem = TodoItem(text: "text", importance: .basic,
                            isDone: true, createdAt: .now)
        
        // Then
        XCTAssertNotEqual(todoItem.id, todoItemAnotherId.id)
    }
    
    
    // MARK: - test TodoItem parse(json: Any)
    
    func testTodoItemParseJsonWithAllProperty() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertEqual("testId", todoItem.id)
        XCTAssertEqual("testText", todoItem.text)
        XCTAssertEqual("low", todoItem.importance.rawValue)
        XCTAssertNotNil(todoItem.deadlineAt)
        XCTAssertEqual(1658797544, todoItem.deadlineAt?.timeIntervalSince1970)
        XCTAssertEqual(false, todoItem.isDone)
        XCTAssertEqual(1658797511, todoItem.createdAt.timeIntervalSince1970)
        XCTAssertNotNil(todoItem.changedAt)
        XCTAssertEqual(1658797533, todoItem.changedAt?.timeIntervalSince1970)
    }
    
    
    func testTodoItemParseJsonWithoutId() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    
    func testTodoItemParseJsonWithoutText() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    
    func testTodoItemParseJsonWithImportanceBasic() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertEqual(Importance.basic.rawValue, todoItem.importance.rawValue)
    }
    
    
    func testTodoItemParseJsonWithImportanceIncorrectType() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": false,
          "deadline": 1658797544,
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    
    func testTodoItemParseJsonWithImportanceIncorrectString() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": "very important",
          "deadline": 1658797544,
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    
    func testTodoItemParseJsonWithoutDeadlineAt() throws {
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
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed),
              let todoItem = TodoItem.parse(json: json)
        else {
            return
        }
        
        // Then
        XCTAssertNotNil(jsonData)
        XCTAssertNotNil(json)
        XCTAssert(JSONSerialization.isValidJSONObject(json))
        XCTAssertNotNil(todoItem)
        
        XCTAssertEqual("testId", todoItem.id)
        XCTAssertEqual("testText", todoItem.text)
        XCTAssertEqual("low", todoItem.importance.rawValue)
        XCTAssertNil(todoItem.deadlineAt)
        XCTAssertEqual(false, todoItem.isDone)
        XCTAssertEqual(1658797511, todoItem.createdAt.timeIntervalSince1970)
        XCTAssertNotNil(todoItem.changedAt)
        XCTAssertEqual(1658797533, todoItem.changedAt?.timeIntervalSince1970)
    }
    
    
    
    

    
    func testTodoItemParseJsonWithDeadlineToDate() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        
        todoItem = parsedTodoItem
        
        // Then
        XCTAssertEqual(Date(timeIntervalSince1970: 1658797544), todoItem.deadlineAt)
    }
    
    
    func testTodoItemParseJsonWithDeadlineLessThanCreatedAt() throws {
        // Given
        let jsonString = """
        {
          "id": "testId",
          "text": "testText",
          "importance": "low",
          "deadline": 165879,
          "done": false,
          "created_at": 1658797511,
          "changed_at": 1658797533
        }
        """
        
        // When
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    
    func testTodoItemParseJsonWithoutCreatedAt() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
            return XCTFail("Get JSON from Data failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json), "Invalid JSON")
        
        // Then
        if let _ = TodoItem.parse(json: json) {
            return XCTFail("Parsing failed")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func testTodoItemParseJsonWithoutChangedAt() throws {
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
        guard let jsonData = jsonString.data(using: .utf8) else {
            return XCTFail("Get Data from String failed")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) else {
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

    
    // MARK: - test property json: Any
    
    func testTodoItemGetJsonWithAllProperty() throws {
        // Given
        todoItem = TodoItem.fixture(id: "testId", text: "testText",
                            importance: .low,
                            deadlineAt: Date(timeIntervalSince1970: 1658923221),
                                isDone: false,
                            createdAt: Date(timeIntervalSince1970: 1658921520),
                            changedAt: Date(timeIntervalSince1970: 1658923221))
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(todoItem.id, parsedTodoItem.id)
        XCTAssertEqual(todoItem.text, parsedTodoItem.text)
        XCTAssertEqual(todoItem.importance, parsedTodoItem.importance)
        XCTAssertEqual(todoItem.deadlineAt, parsedTodoItem.deadlineAt)
        XCTAssertEqual(todoItem.isDone, parsedTodoItem.isDone)
        XCTAssertEqual(todoItem.createdAt, parsedTodoItem.createdAt)
        XCTAssertEqual(todoItem.changedAt, parsedTodoItem.changedAt)
    }
    
    
    func testTodoItemGetJsonWithId() throws {
        // Given
        let todoItem = TodoItem.fixture(id: "testId", importance: .low)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(parsedTodoItem.id, "testId")
    }
    
    
    func testTodoItemGetJsonWithText() throws {
        // Given
        let todoItem = TodoItem.fixture(text: "testText", importance: .low)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(parsedTodoItem.text, "testText")
    }
    
    
    func testTodoItemGetJsonWithImportanceImportant() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .important)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(parsedTodoItem.importance.rawValue, "important")
    }
    
    
    func testTodoItemGetJsonWithImportanceBasic() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .basic)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(parsedTodoItem.importance.rawValue, "basic")
    }
    
    
    func testTodoItemGetJsonWithDeadlineAt() throws {
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
    
    
    func testTodoItemGetJsonWithIsDone() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .basic,
                                        isDone: true)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssert(parsedTodoItem.isDone)
    }
    
    
    func testTodoItemGetJsonWithCreatedAt() throws {
        // Given
        let date = Date(timeIntervalSince1970: 1658954778)
        let todoItem = TodoItem.fixture(importance: .low,
                                        createdAt: date)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(parsedTodoItem.createdAt, date)
    }
    
    
    func testTodoItemGetJsonWithChangedAt() throws {
        // Given
        let date = Date(timeIntervalSince1970: 1658954778)
        let todoItem = TodoItem.fixture(importance: .low,
                                        changedAt: date)
        let json = todoItem.json
        
        // When
        guard let parsedTodoItem = TodoItem.parse(json: json) else {
            return XCTFail("Parsing failed")
        }
        XCTAssert(JSONSerialization.isValidJSONObject(json))

        // Then
        XCTAssertEqual(parsedTodoItem.changedAt, date)
    }
}
