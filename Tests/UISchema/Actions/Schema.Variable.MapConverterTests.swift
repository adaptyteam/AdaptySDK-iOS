//
//  Schema.Variable.ConverterTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 02.03.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.VariableTests {
    struct MapConvertorTests {
        typealias Value = Schema.Variable.MapConvertor

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                Value(values: []),
                Json(##"{"converter":"map", "converter_params":[] }"##)
            ),
            (
                Value(values: [VC.AnyValue(1), VC.AnyValue(2), VC.AnyValue(3)]),
                Json(##"{"converter":"map", "converter_params":[1,2,3]}"##)
            ),
            (
                Value(values: [VC.AnyValue("1"), VC.AnyValue("2"), VC.AnyValue("3")]),
                Json(##"{"converter":"map", "converter_params":["1","2","3"]}"##)
            ),
            (
                Value(values: [VC.AnyValue(1), VC.AnyValue("2"), VC.AnyValue(3.5)]),
                Json(##"{"converter":"map", "converter_params":[1,"2",3.5]}"##)
            ),
            (
                Value(values: [VC.AnyValue(true), VC.AnyValue(false), VC.AnyValue(false)]),
                Json(##"{"converter":"map", "converter_params":[true,false,false]}"##)
            ),
            (
                Value(values: [
                    VC.AnyValue([VC.AnyValue(1), VC.AnyValue(2), VC.AnyValue(3)]),
                    VC.AnyValue(["s": VC.AnyValue("str"), "b": VC.AnyValue(true)]),
                ]),
                Json(##"{"converter":"map", "converter_params":[[1,2,3],{ "s":"str","b":true }]}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##"{"converter": "map", "converter_params": "foo"}"##),
            Json(##"{"converter": "map", "converter_params": { "foo": 123 } }"##),
            Json(##"{"converter": "map"}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid variable", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }
    }
}

