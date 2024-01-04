//
//  EventCollectionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 13.10.2022
//

@testable import Adapty
import XCTest

final class EventCollectionTests: XCTestCase {
    func testRemoveAll() {
        var collection1 = EventCollection<Int>(elements: [], startIndex: 10)
        collection1.removeAll()
        XCTAssertEqual(collection1.elements, [])
        XCTAssertEqual(collection1.startIndex, 10)

        var collection2 = EventCollection<Int>(elements: [6, 7, 8, 9], startIndex: 6)
        collection2.removeAll()
        XCTAssertEqual(collection2.elements, [])
        XCTAssertEqual(collection2.startIndex, 10)

        var collection3 = EventCollection<Int>(elements: [0, 1, 2, 3, 4, 5], startIndex: 0)
        collection3.removeAll()
        XCTAssertEqual(collection3.elements, [])
        XCTAssertEqual(collection3.startIndex, 6)
    }

    func testRemoveFirstZeroElements() {
        for k in -3 ... 0 {
            var collection = EventCollection<Int>(elements: [10, 11, 12], startIndex: 10)
            collection.removeFirst(k)
            XCTAssertEqual(collection.elements, [10, 11, 12])
            XCTAssertEqual(collection.startIndex, 10)
        }
    }

    func testRemoveFirstFromEmptyCollection() {
        for k in -3 ... 3 {
            var collection = EventCollection<Int>(elements: [], startIndex: 10)
            collection.removeFirst(k)
            XCTAssertEqual(collection.elements, [])
            XCTAssertEqual(collection.startIndex, 10)
        }
    }

    func testRemoveFirstInSmallCollection() {
        for k in 3 ... 5 {
            var collection = EventCollection<Int>(elements: [10, 11, 12], startIndex: 10)
            collection.removeFirst(k)
            XCTAssertEqual(collection.elements, [])
            XCTAssertEqual(collection.startIndex, 13)
        }
    }

    func testRemoveFirst() {
        var collection = EventCollection<Int>(elements: [10, 11, 12, 13, 14, 15], startIndex: 10)
        collection.removeFirst(3)
        XCTAssertEqual(collection.elements, [13, 14, 15])
        XCTAssertEqual(collection.startIndex, 13)
        collection.removeFirst(2)
        XCTAssertEqual(collection.elements, [15])
        XCTAssertEqual(collection.startIndex, 15)
    }

    func testAppend() {
        var collection = EventCollection<Int>(elements: [], startIndex: 10)
        collection.append(10)
        XCTAssertEqual(collection.elements, [10])
        XCTAssertEqual(collection.startIndex, 10)
        collection.append(11)
        XCTAssertEqual(collection.elements, [10, 11])
        XCTAssertEqual(collection.startIndex, 10)
        collection.append(12)
        XCTAssertEqual(collection.elements, [10, 11, 12])
        XCTAssertEqual(collection.startIndex, 10)
        collection.append(13)
        XCTAssertEqual(collection.elements, [10, 11, 12, 13])
        XCTAssertEqual(collection.startIndex, 10)
    }

    func testAppendWithLimit() {
        var collection = EventCollection<Int>(elements: [], startIndex: 10)
        collection.append(10, withLimit: 3)
        XCTAssertEqual(collection.elements, [10])
        XCTAssertEqual(collection.startIndex, 10)
        collection.append(11, withLimit: 3)
        XCTAssertEqual(collection.elements, [10, 11])
        XCTAssertEqual(collection.startIndex, 10)
        collection.append(12, withLimit: 3)
        XCTAssertEqual(collection.elements, [10, 11, 12])
        XCTAssertEqual(collection.startIndex, 10)
        collection.append(13, withLimit: 3)
        XCTAssertEqual(collection.elements, [11, 12, 13])
        XCTAssertEqual(collection.startIndex, 11)
        collection.append(14, withLimit: 3)
        XCTAssertEqual(collection.elements, [12, 13, 14])
        XCTAssertEqual(collection.startIndex, 12)
        collection.append(15, withLimit: 3)
        XCTAssertEqual(collection.elements, [13, 14, 15])
        XCTAssertEqual(collection.startIndex, 13)
    }

    func testRemoveToLimit() {
        var collection = EventCollection<Int>(elements: [10, 11, 12, 13, 14, 15, 16, 17, 18], startIndex: 10)
        for k in -5 ... -1 {
            collection.remove(toLimit: k)
            XCTAssertEqual(collection.elements, [10, 11, 12, 13, 14, 15, 16, 17, 18])
            XCTAssertEqual(collection.startIndex, 10)
        }
        collection.remove(toLimit: 8)
        XCTAssertEqual(collection.elements, [11, 12, 13, 14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 11)
        collection.remove(toLimit: 8)
        XCTAssertEqual(collection.elements, [11, 12, 13, 14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 11)
        collection.remove(toLimit: 20)
        XCTAssertEqual(collection.elements, [11, 12, 13, 14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 11)
        collection.remove(toLimit: 5)
        XCTAssertEqual(collection.elements, [14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 14)
        collection.remove(toLimit: 2)
        XCTAssertEqual(collection.elements, [17, 18])
        XCTAssertEqual(collection.startIndex, 17)
        collection.remove(toLimit: 0)
        XCTAssertEqual(collection.elements, [])
        XCTAssertEqual(collection.startIndex, 19)
    }

    func testSubstruct() {
        var collection = EventCollection<Int>(elements: [10, 11, 12, 13, 14, 15, 16, 17, 18], startIndex: 10)
        collection.subtract(newStartIndex: 14)
        XCTAssertEqual(collection.elements, [14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 14)

        collection.subtract(newStartIndex: 10)
        XCTAssertEqual(collection.elements, [14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 14)

        collection.subtract(newStartIndex: 14)
        XCTAssertEqual(collection.elements, [14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 14)

        collection.subtract(newStartIndex: -4)
        XCTAssertEqual(collection.elements, [14, 15, 16, 17, 18])
        XCTAssertEqual(collection.startIndex, 14)

        collection.subtract(newStartIndex: 18)
        XCTAssertEqual(collection.elements, [18])
        XCTAssertEqual(collection.startIndex, 18)

        collection.subtract(newStartIndex: 20)
        XCTAssertEqual(collection.elements, [])
        XCTAssertEqual(collection.startIndex, 19)
    }
}
