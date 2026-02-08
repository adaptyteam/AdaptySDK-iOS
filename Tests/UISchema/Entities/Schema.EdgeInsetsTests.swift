//
//  Schema.EdgeInsetsTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.EdgeInsets Tests")
    struct EdgeInsetsTests {
        typealias Value = Schema.EdgeInsets

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Unit format (single value → same for all edges)
            (
                Value(same: .point(10)),
                Json(##"10"##)
            ),
            (
                Value(same: .point(0)),
                Json(##"0"##)
            ),
            (
                Value(same: .point(5.5)),
                Json(##"{"point":5.5}"##)
            ),
            (
                Value(same: .screen(0.5)),
                Json(##"{"screen":0.5}"##)
            ),
            (
                Value(same: .safeArea(.start)),
                Json(##"{"safe_area":"start"}"##)
            ),
            // Array empty or one element format
            (
                Value(same: .point(0)),
                Json(##"[]"##)
            ),
            (
                Value(same: .point(0)),
                Json(##"[0]"##)
            ),
            (
                Value(same: .point(5)),
                Json(##"[5]"##)
            ),
            (
                Value(same: .screen(0.5)),
                Json(##"[{"screen":0.5}]"##)
            ),
            // Array two element format
            // [vertical, horizontal] → top=bottom=values[0], leading=trailing=values[1]
            (
                Value(leading: .point(20), top: .point(10), trailing: .point(20), bottom: .point(10)),
                Json(##"[10,20]"##)
            ),
            (
                Value(leading: .screen(0.5), top: .point(0), trailing: .screen(0.5), bottom: .point(0)),
                Json(##"[0,{"screen":0.5}]"##)
            ),
            // Array three or more element format
            // 3 elements: [leading, top, trailing], bottom=.zero
            // 4 elements: [leading, top, trailing, bottom]
            (
                Value(leading: .point(1), top: .point(2), trailing: .point(3), bottom: .zero),
                Json(##"[1,2,3]"##)
            ),
            (
                Value(leading: .point(1), top: .point(2), trailing: .point(3), bottom: .point(4)),
                Json(##"[1,2,3,4]"##)
            ),
            (
                Value(leading: .point(1), top: .point(2), trailing: .point(3), bottom: .point(4)),
                Json(##"[1,2,3,4,5]"##)
            ),
            // Object format
            (
                Value(leading: .point(2), top: .point(1), trailing: .point(4), bottom: .point(3)),
                Json(##"{"top":1,"leading":2,"bottom":3,"trailing":4}"##)
            ),
            (
                Value(leading: .zero, top: .screen(0.5), trailing: .zero, bottom: .zero),
                Json(##"{"top":{"screen":0.5}}"##)
            ),
            (
                Value(leading: .point(10), top: .zero, trailing: .zero, bottom: .zero),
                Json(##"{"leading":10}"##)
            ),
            (
                Value(leading: .zero, top: .zero, trailing: .point(10), bottom: .zero),
                Json(##"{"trailing":10}"##)
            ),
            (
                Value(leading: .zero, top: .zero, trailing: .zero, bottom: .point(10)),
                Json(##"{"bottom":10}"##)
            ),
            (
                Value(same: .point(0)),
                Json(##"{}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##""string""##),
            Json(##"true"##),
            Json(##"["a","b"]"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode from unit, array, and object formats", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded.leading == value.leading)
            #expect(decoded.top == value.top)
            #expect(decoded.trailing == value.trailing)
            #expect(decoded.bottom == value.bottom)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }
    }
}
