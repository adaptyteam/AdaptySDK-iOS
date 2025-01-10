//
//  EventCollectionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 13.10.2022
//

#if canImport(Testing)

@testable import Adapty
import Testing

struct EventCollectionTests {
    @Test func removeAll() {
        var collection1 = EventCollection<Int>(elements: [], startIndex: 10)
        collection1.removeAll()
        #expect(collection1.elements == [])
        #expect(collection1.startIndex == 10)

        var collection2 = EventCollection<Int>(elements: [6, 7, 8, 9], startIndex: 6)
        collection2.removeAll()
        #expect(collection2.elements == [])
        #expect(collection2.startIndex == 10)

        var collection3 = EventCollection<Int>(elements: [0, 1, 2, 3, 4, 5], startIndex: 0)
        collection3.removeAll()
        #expect(collection3.elements == [])
        #expect(collection3.startIndex == 6)
    }

    @Test func removeFirstZeroElements() {
        for k in -3 ... 0 {
            var collection = EventCollection<Int>(elements: [10, 11, 12], startIndex: 10)
            collection.removeFirst(k)
            #expect(collection.elements == [10, 11, 12])
            #expect(collection.startIndex == 10)
        }
    }

    @Test func removeFirstFromEmptyCollection() {
        for k in -3 ... 3 {
            var collection = EventCollection<Int>(elements: [], startIndex: 10)
            collection.removeFirst(k)
            #expect(collection.elements == [])
            #expect(collection.startIndex == 10)
        }
    }

    @Test func removeFirstInSmallCollection() {
        for k in 3 ... 5 {
            var collection = EventCollection<Int>(elements: [10, 11, 12], startIndex: 10)
            collection.removeFirst(k)
            #expect(collection.elements == [])
            #expect(collection.startIndex == 13)
        }
    }

    @Test func removeFirst() {
        var collection = EventCollection<Int>(elements: [10, 11, 12, 13, 14, 15], startIndex: 10)
        collection.removeFirst(3)
        #expect(collection.elements == [13, 14, 15])
        #expect(collection.startIndex == 13)
        collection.removeFirst(2)
        #expect(collection.elements == [15])
        #expect(collection.startIndex == 15)
    }

    @Test func append() {
        var collection = EventCollection<Int>(elements: [], startIndex: 10)
        collection.append(10)
        #expect(collection.elements == [10])
        #expect(collection.startIndex == 10)
        collection.append(11)
        #expect(collection.elements == [10, 11])
        #expect(collection.startIndex == 10)
        collection.append(12)
        #expect(collection.elements == [10, 11, 12])
        #expect(collection.startIndex == 10)
        collection.append(13)
        #expect(collection.elements == [10, 11, 12, 13])
        #expect(collection.startIndex == 10)
    }

    @Test func appendWithLimit() {
        var collection = EventCollection<Int>(elements: [], startIndex: 10)
        collection.append(10, withLimit: 3)
        #expect(collection.elements == [10])
        #expect(collection.startIndex == 10)
        collection.append(11, withLimit: 3)
        #expect(collection.elements == [10, 11])
        #expect(collection.startIndex == 10)
        collection.append(12, withLimit: 3)
        #expect(collection.elements == [10, 11, 12])
        #expect(collection.startIndex == 10)
        collection.append(13, withLimit: 3)
        #expect(collection.elements == [11, 12, 13])
        #expect(collection.startIndex == 11)
        collection.append(14, withLimit: 3)
        #expect(collection.elements == [12, 13, 14])
        #expect(collection.startIndex == 12)
        collection.append(15, withLimit: 3)
        #expect(collection.elements == [13, 14, 15])
        #expect(collection.startIndex == 13)
    }

    @Test func removeToLimit() {
        var collection = EventCollection<Int>(elements: [10, 11, 12, 13, 14, 15, 16, 17, 18], startIndex: 10)
        for k in -5 ... -1 {
            collection.remove(toLimit: k)
            #expect(collection.elements == [10, 11, 12, 13, 14, 15, 16, 17, 18])
            #expect(collection.startIndex == 10)
        }
        collection.remove(toLimit: 8)
        #expect(collection.elements == [11, 12, 13, 14, 15, 16, 17, 18])
        #expect(collection.startIndex == 11)
        collection.remove(toLimit: 8)
        #expect(collection.elements == [11, 12, 13, 14, 15, 16, 17, 18])
        #expect(collection.startIndex == 11)
        collection.remove(toLimit: 20)
        #expect(collection.elements == [11, 12, 13, 14, 15, 16, 17, 18])
        #expect(collection.startIndex == 11)
        collection.remove(toLimit: 5)
        #expect(collection.elements == [14, 15, 16, 17, 18])
        #expect(collection.startIndex == 14)
        collection.remove(toLimit: 2)
        #expect(collection.elements == [17, 18])
        #expect(collection.startIndex == 17)
        collection.remove(toLimit: 0)
        #expect(collection.elements == [])
        #expect(collection.startIndex == 19)
    }

    @Test func substruct() {
        var collection = EventCollection<Int>(elements: [10, 11, 12, 13, 14, 15, 16, 17, 18], startIndex: 10)
        collection.subtract(newStartIndex: 14)
        #expect(collection.elements == [14, 15, 16, 17, 18])
        #expect(collection.startIndex == 14)

        collection.subtract(newStartIndex: 10)
        #expect(collection.elements == [14, 15, 16, 17, 18])
        #expect(collection.startIndex == 14)

        collection.subtract(newStartIndex: 14)
        #expect(collection.elements == [14, 15, 16, 17, 18])
        #expect(collection.startIndex == 14)

        collection.subtract(newStartIndex: -4)
        #expect(collection.elements == [14, 15, 16, 17, 18])
        #expect(collection.startIndex == 14)

        collection.subtract(newStartIndex: 18)
        #expect(collection.elements == [18])
        #expect(collection.startIndex == 18)

        collection.subtract(newStartIndex: 20)
        #expect(collection.elements == [])
        #expect(collection.startIndex == 19)
    }
}
#endif
