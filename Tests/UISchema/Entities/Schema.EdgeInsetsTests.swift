//
//  Schema.EdgeInsetsTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.EdgeInsets Tests")
    struct SchemaEdgeInsetsTests {
        typealias Value = Schema.EdgeInsets
        typealias Unit = Schema.Unit

        // MARK: - Test Data

        static let decodeCases: [(value: Value, json: String)] = [
            // Unit format (single value → same for all edges)
            (
                Value(same: .point(10)),
                json: "10"
            ),
            (
                Value(same: .point(0)),
                json: "0"
            ),
            (
                Value(same: .point(5.5)),
                json: #"{"point":5.5}"#
            ),
            (
                Value(same: .screen(0.5)),
                json: #"{"screen":0.5}"#
            ),
            (
                Value(same: .safeArea(.start)),
                json: #"{"safe_area":"start"}"#
            ),
            // Array empty or one element format
            (
                Value(same: .point(0)),
                json: "[]"
            ),
            (
                Value(same: .point(0)),
                json: "[0]"
            ),
            (
                Value(same: .point(5)),
                json: "[5]"
            ),
            (
                Value(same: .screen(0.5)),
                json: #"[{"screen":0.5}]"#
            ),
            // Array two element format
            // [vertical, horizontal] → top=bottom=values[0], leading=trailing=values[1]
            (
                Value(leading: .point(20), top: .point(10), trailing: .point(20), bottom: .point(10)),
                json: "[10,20]"
            ),
            (
                Value(leading: .screen(0.5), top: .point(0), trailing: .screen(0.5), bottom: .point(0)),
                json: #"[0,{"screen":0.5}]"#
            ),
            // Array three or more element format
            // 3 elements: [leading, top, trailing], bottom=.zero
            // 4 elements: [leading, top, trailing, bottom]
            (
                Value(leading: .point(1), top: .point(2), trailing: .point(3), bottom: .zero),
                json: "[1,2,3]"
            ),
            (
                Value(leading: .point(1), top: .point(2), trailing: .point(3), bottom: .point(4)),
                json: "[1,2,3,4]"
            ),
            (
                Value(leading: .point(1), top: .point(2), trailing: .point(3), bottom: .point(4)),
                json: "[1,2,3,4,5]"
            ),
            // Object format
            (
                Value(leading: .point(2), top: .point(1), trailing: .point(4), bottom: .point(3)),
                json: #"{"top":1,"leading":2,"bottom":3,"trailing":4}"#
            ),
            (
                Value(leading: .zero, top: .screen(0.5), trailing: .zero, bottom: .zero),
                json: #"{"top":{"screen":0.5}}"#
            ),
            (
                Value(leading: .point(10), top: .zero, trailing: .zero, bottom: .zero),
                json: #"{"leading":10}"#
            ),
            (
                Value(leading: .zero, top: .zero, trailing: .point(10), bottom: .zero),
                json: #"{"trailing":10}"#
            ),
            (
                Value(leading: .zero, top: .zero, trailing: .zero, bottom: .point(10)),
                json: #"{"bottom":10}"#
            ),
            (
                Value(same: .point(0)),
                json: "{}"
            ),
        ]

        static let invalidJsons: [String] = [
            #""string""#,
            "true",
            #"["a","b"]"#,
        ]

        // MARK: - Decoding Tests

        @Test("decode from unit, array, and object formats", arguments: decodeCases)
        func decode(value: Value, json: String) throws {
            let data = "[\(json)]".data(using: .utf8)!
            let result = try JSONDecoder().decode([Value].self, from: data)
            #expect(result.count == 1)
            #expect(result[0].leading == value.leading)
            #expect(result[0].top == value.top)
            #expect(result[0].trailing == value.trailing)
            #expect(result[0].bottom == value.bottom)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(json: String) {
            let data = "[\(json)]".data(using: .utf8)!
            #expect(throws: (any Error).self) {
                try JSONDecoder().decode([Value].self, from: data)
            }
        }
    }
}
