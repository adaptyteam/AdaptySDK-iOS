//
//  JSValueRepresentableTests+Bool.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

@testable import AdaptyUIBuilder
import Testing

extension JSValueRepresentableTests {
    struct BoolTests {
        @Test("convert JavaScript value to Bool", arguments: [
            (script: "true", expected: true),
            (script: "false", expected: false),
            (script: "4", expected: true),
            (script: "0", expected: false),
            (script: "NaN", expected: false),
            (script: "Infinity", expected: true),
            (script: #""""#, expected: false),
            (script: #""abc""#, expected: true),
            (script: "[]", expected: true),
            (script: "({})", expected: true),
            (script: "({ valueOf() { throw new Error('valueOf failed') } })", expected: true),
            (script: "Symbol('value')", expected: true),
        ])
        func convert(script: String, expected: Bool) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Bool.fromJSValue(value) == expected)
        }

        @Test("convert nullish JavaScript value to nil", arguments: [
            "undefined",
            "null",
        ])
        func convertNullish(script: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Bool.fromJSValue(value) == nil)
        }
    }
}
