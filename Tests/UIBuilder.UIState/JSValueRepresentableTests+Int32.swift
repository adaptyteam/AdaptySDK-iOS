//
//  JSValueRepresentableTests+Int32.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

@testable import AdaptyUIBuilder
import Testing

extension JSValueRepresentableTests {
    struct Int32Tests {
        @Test("convert JavaScript value to Int32", arguments: [
            (script: "true", expected: 1),
            (script: "false", expected: 0),
            (script: "4", expected: 4),
            (script: "-4.9", expected: -4),
            (script: "NaN", expected: 0),
            (script: "Infinity", expected: 0),
            (script: #""""#, expected: 0),
            (script: #""4""#, expected: 4),
            (script: #""abc""#, expected: 0),
            (script: "[]", expected: 0),
            (script: "[4]", expected: 4),
            (script: "({})", expected: 0),
            (script: "4n", expected: 4),
            (script: "2147483648", expected: .min),
            (script: "4294967295", expected: -1),
            (script: "4294967296", expected: 0),
        ])
        func convert(script: String, expected: Int32) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Int32.fromJSValue(value) == expected)
        }

        @Test("return zero and report JavaScript conversion exception", arguments: [
            "Symbol('value')",
            "({ valueOf() { throw new Error('valueOf failed') } })",
        ])
        func convertException(script: String) throws {
            let (context, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Int32.fromJSValue(value) == 0)
            #expect(context.exception != nil)
        }

        @Test("convert nullish JavaScript value to nil", arguments: [
            "undefined",
            "null",
        ])
        func convertNullish(script: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Int32.fromJSValue(value) == nil)
        }
    }
}
