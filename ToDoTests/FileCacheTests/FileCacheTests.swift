//
//  FileCacheTests.swift
//  ToDoTests
//
//  Created by Timur on 31.07.2022.
//

import XCTest
@testable import ToDo

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
        let todoItem1 = TodoItem.fixture(
            id: "first",
            importance: .low
        )
        let todoItem2 = TodoItem.fixture(
            id: "second",
            importance: .low
        )
        
        // When
        do {
            try fileCache.add(todoItem: todoItem1)
            try fileCache.add(todoItem: todoItem2)
        }
        catch {
            XCTFail("Add error")
        }
        
        // Then
        XCTAssertEqual(
            fileCache.items.count,
            2
        )
    }
    
    func testAddSameTodoItems() throws {
        // Given
        let todoItem1 = TodoItem.fixture(
            id: "first",
            importance: .low
        )
        let todoItem2 = todoItem1
        
        // When
        XCTAssertNoThrow(try fileCache.add(todoItem: todoItem1))
        
        XCTAssertThrowsError(try fileCache.add(todoItem: todoItem2))
        
        // Then
        XCTAssertEqual(
            fileCache.items.count,
            1
        )
    }
    
    func testAddSameIdDifferentImportance() throws {
        // Given
        let todoItem1 = TodoItem.fixture(
            id: "first",
            importance: .low
        )
        let todoItem2 = TodoItem.fixture(
            id: "first",
            importance: .basic
        )
        
        // When
        XCTAssertNoThrow(try fileCache.add(todoItem: todoItem1))
        
        XCTAssertThrowsError(try fileCache.add(todoItem: todoItem2))
        
        // Then
        XCTAssertEqual(
            fileCache.items.count,
            1
        )
    }
    
    func testDeleteEmpty() throws {
        // Given
        let todoItem = TodoItem.fixture(importance: .low)
        
        // When
        XCTAssertThrowsError(try fileCache.delete(id: todoItem.id))
        
        // Then
        XCTAssertEqual(
            fileCache.items.count,
            0
        )
    }
    
    func testDeleteTodoItem() throws {
        // Given
        let todoItem1 = TodoItem.fixture(
            id: "first",
            importance: .low
        )
        let todoItem2 = TodoItem.fixture(
            id: "second",
            importance: .low
        )
        
        // When
        do {
            try fileCache.add(todoItem: todoItem1)
            try fileCache.add(todoItem: todoItem2)
        }
        catch {
            XCTFail("Add error")
        }
        
        XCTAssertNoThrow(try fileCache.delete(id: todoItem1.id))
        
        // Then
        XCTAssertNil(fileCache.items["first"])
        XCTAssertEqual(
            fileCache.items.count,
            1
        )
    }
    
    func testContains() throws {
        // Given
        let todoItem = TodoItem.fixture(
            id: "test",
            importance: .low
        )
        
        // Then
        XCTAssertNoThrow(try fileCache.add(todoItem: todoItem))
        XCTAssert(fileCache.contains(todoItem: todoItem))
    }
    
    // MARK: - Test save, load, contains
    func testSaveInEmptyDir() throws {
        // Given
        let todoItem1 = TodoItem.fixture(
            id: "first",
            importance: .low
        )
        let todoItem2 = TodoItem.fixture(
            id: "second",
            importance: .basic
        )
        let todoItem3 = TodoItem.fixture(
            id: "third",
            importance: .important
        )
        
        let anotherFileCache = FileCache()
        
        // When
        for todoItem in [todoItem1, todoItem2, todoItem3] {
            XCTAssertNoThrow(try fileCache.add(todoItem: todoItem))
        }
        
        XCTAssertNoThrow(try fileCache.save(to: "Test"))
        
        // Then
        XCTAssertNoThrow(try anotherFileCache.load(from: "Test"))
        XCTAssertEqual(anotherFileCache.items.keys.count, 3)
        
        XCTAssert(anotherFileCache.contains(todoItem: todoItem1))
        XCTAssert(anotherFileCache.contains(todoItem: todoItem2))
        XCTAssert(anotherFileCache.contains(todoItem: todoItem3))
        
        XCTAssertNoThrow(try fileCache.clearCache(by: "Test"))
    }
    
    func testSaveInNotEmptyDir() throws {
        // Given
        let todoItem1 = TodoItem.fixture(
            id: "first",
            importance: .low
        )
        let todoItem2 = TodoItem.fixture(
            id: "second",
            importance: .basic
        )
        
        let anotherFileCache = FileCache()
        let anotherTodoItem = TodoItem.fixture(
            id: "anotherFirst",
            importance: .important
        )
        
        // When
        for todoItem in [todoItem1, todoItem2] {
            XCTAssertNoThrow(try fileCache.add(todoItem: todoItem))
        }
        
        XCTAssertNoThrow(try anotherFileCache.add(todoItem: anotherTodoItem))
        
        XCTAssertNoThrow(try fileCache.save(to: "Test"))
        XCTAssertEqual(
            anotherFileCache.items.keys.count,
            1
        )
        
        // Then
        XCTAssertNoThrow(try anotherFileCache.save(to: "Test"))
        
        XCTAssertNoThrow(try anotherFileCache.load(from: "Test"))
        XCTAssertEqual(
            anotherFileCache.items.keys.count,
            3
        )
        
        XCTAssert(anotherFileCache.contains(todoItem: todoItem1))
        XCTAssert(anotherFileCache.contains(todoItem: todoItem2))
        XCTAssert(anotherFileCache.contains(todoItem: anotherTodoItem))
        
        XCTAssertNoThrow(try fileCache.clearCache(by: "Test"))
    }
}
