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
    
    
    // MARK: - Test isBasic
    
    func testIsBasicWithLow() throws {
        // When
        importance = .low
        // Then
        XCTAssert(!importance.isBasic())
    }
    
    func testIsBasicWithBasic() throws {
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
    
    
    // MARK: - Test struct TodoItem
    
    func testWithNilDeadlineAt() throws {
        // When
        todoItem = TodoItem(text: "text", importance: .basic,
                            isDone: true, createdAt: .now)
        // Then
        XCTAssertNil(todoItem.deadlineAt)
    }
    
    
    func testWithNilChangedAt() throws {
        // When
        todoItem = TodoItem(text: "text", importance: .basic,
                            isDone: true, createdAt: .now)
        // Then
        XCTAssertNil(todoItem.changedAt)
    }
    
    
    func testUUID() throws {
        // Given
        let todoItemAnotherId = TodoItem(text: "text", importance: .basic,
                                         isDone: true, createdAt: .now)
        
        // When
        todoItem = TodoItem(text: "text", importance: .basic,
                            isDone: true, createdAt: .now)
        
        // Then
        XCTAssertNotEqual(todoItem.id, todoItemAnotherId.id)
    }
    
    
    // MARK: - Test TodoItem parse(json: Any)
    
    func testParseJsonWithAllProperty() throws {
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
    
    
    func testParseJsonWithImportanceIncorrectType() throws {
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
    
    
    func testParseJsonWithImportanceIncorrectString() throws {
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
    
    
    func testParseJsonWithDeadlineLessThanCreatedAt() throws {
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
    
    
    // MARK: - Test property json: Any
    
    func testGetJsonWithAllProperty() throws {
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
    
    
    func testGetJsonWithId() throws {
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
    
    
    func testGetJsonWithText() throws {
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
        XCTAssertEqual(parsedTodoItem.importance.rawValue, "important")
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
        XCTAssertEqual(parsedTodoItem.importance.rawValue, "basic")
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
    
    
    func testGetJsonWithCreatedAt() throws {
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
    
    
    func testGetJsonWithChangedAt() throws {
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


class FileCacheTests: XCTestCase {
    
    var fileCache: FileCache!
    
    override func setUpWithError() throws {
        fileCache = FileCache()
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        fileCache = nil
        try super.tearDownWithError()
    }
    
    
    // MARK: - Test add, delete
    func testAddDifferentId() throws {
        // Given
        let todoItem1 = TodoItem.fixture(id: "first", importance: .low)
        let todoItem2 = TodoItem.fixture(id: "second", importance: .low)
        
        // When
        do {
            try fileCache.add(todoItem: todoItem1)
            try fileCache.add(todoItem: todoItem2)
        }
        catch {
            XCTFail("Add error")
        }
        
        // Then
        XCTAssertEqual(fileCache.dictTodoItems.count, 2)
    }
    
    
    func testAddSameTodoItems() throws {
        // Given
        let todoItem1 = TodoItem.fixture(id: "first", importance: .low)
        let todoItem2 = todoItem1
        
        // When
        XCTAssertNoThrow(try fileCache.add(todoItem: todoItem1))
        
        XCTAssertThrowsError(try fileCache.add(todoItem: todoItem2))
        
        // Then
        XCTAssertEqual(fileCache.dictTodoItems.count, 1)
    }
    
    
    func testAddSameIdDifferentImportance() throws {
        // Given
        let todoItem1 = TodoItem.fixture(id: "first", importance: .low)
        let todoItem2 = TodoItem.fixture(id: "first", importance: .basic)
        
        // When
        XCTAssertNoThrow(try fileCache.add(todoItem: todoItem1))
        
        XCTAssertThrowsError(try fileCache.add(todoItem: todoItem2))
        
        // Then
        XCTAssertEqual(fileCache.dictTodoItems.count, 1)
    }
    
    
    func testDeleteEmpty() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .low)
        
        // When
        XCTAssertThrowsError(try fileCache.delete(todoItem: todoItem))
        
        // Then
        XCTAssertEqual(fileCache.dictTodoItems.count, 0)
    }
    
    
    func testDeleteTodoItem() throws {
        // Given
        let todoItem1 = TodoItem.fixture(id: "first", importance: .low)
        let todoItem2 = TodoItem.fixture(id: "second", importance: .low)
        
        // When
        do {
            try fileCache.add(todoItem: todoItem1)
            try fileCache.add(todoItem: todoItem2)
        }
        catch {
            XCTFail("Add error")
        }
        
        XCTAssertNoThrow(try fileCache.delete(todoItem: todoItem1))
        
        // Then
        XCTAssertNil(fileCache.dictTodoItems["first"])
        XCTAssertEqual(fileCache.dictTodoItems.count, 1)
    }
    
    
    func testContains() throws {
        // Given
        let todoItem = TodoItem.fixture(id: "test", importance: .low)
        
        // Then
        XCTAssertNoThrow(try fileCache.add(todoItem: todoItem))
        XCTAssert(fileCache.contains(todoItem: todoItem))
    }
    
    
    // MARK: - Test save, load, contains
    func testSaveInEmptyDir() throws {
        // Given
        let todoItem1 = TodoItem.fixture(id: "first", importance: .low)
        let todoItem2 = TodoItem.fixture(id: "second", importance: .basic)
        let todoItem3 = TodoItem.fixture(id: "third", importance: .important)
        
        let anotherFileCache = FileCache()
        
        // When
        for todoItem in [todoItem1, todoItem2, todoItem3] {
            XCTAssertNoThrow(try fileCache.add(todoItem: todoItem))
        }
        
        XCTAssertNoThrow(try fileCache.save(to: "Test"))
        
        // Then
        XCTAssertNoThrow(try anotherFileCache.load(from: "Test"))
        XCTAssertEqual(anotherFileCache.dictTodoItems.keys.count, 3)
        
        XCTAssert(anotherFileCache.contains(todoItem: todoItem1))
        XCTAssert(anotherFileCache.contains(todoItem: todoItem2))
        XCTAssert(anotherFileCache.contains(todoItem: todoItem3))
        
        XCTAssertNoThrow(try fileCache.removeDir(by: "Test"))
    }
    
    
    func testSaveInNotEmptyDir() throws {
        // Given
        let todoItem1 = TodoItem.fixture(id: "first", importance: .low)
        let todoItem2 = TodoItem.fixture(id: "second", importance: .basic)
        
        let anotherFileCache = FileCache()
        let anotherTodoItem = TodoItem.fixture(id: "anotherFirst", importance: .important)
        
        // When
        for todoItem in [todoItem1, todoItem2] {
            XCTAssertNoThrow(try fileCache.add(todoItem: todoItem))
        }
        
        XCTAssertNoThrow(try anotherFileCache.add(todoItem: anotherTodoItem))
        
        XCTAssertNoThrow(try fileCache.save(to: "Test"))
        XCTAssertEqual(anotherFileCache.dictTodoItems.keys.count, 1)
        
        // Then
        XCTAssertNoThrow(try anotherFileCache.save(to: "Test"))
        
        XCTAssertNoThrow(try anotherFileCache.load(from: "Test"))
        XCTAssertEqual(anotherFileCache.dictTodoItems.keys.count, 3)
        
        XCTAssert(anotherFileCache.contains(todoItem: todoItem1))
        XCTAssert(anotherFileCache.contains(todoItem: todoItem2))
        XCTAssert(anotherFileCache.contains(todoItem: anotherTodoItem))
        
        XCTAssertNoThrow(try fileCache.removeDir(by: "Test"))
    }
}
