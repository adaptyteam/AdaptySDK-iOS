//
//  JSValueRepresentableTests+String.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

@testable import AdaptyUIBuilder
import Testing

extension JSValueRepresentableTests {
    struct StringTests {
        @Test("convert JavaScript value to String", arguments: [
            (script: #""""#, expected: ""),
            (script: #""abc""#, expected: "abc"),
            (script: "4", expected: "4"),
            (script: "true", expected: "true"),
            (script: "NaN", expected: "NaN"),
            (script: "Infinity", expected: "Infinity"),
            (script: "[]", expected: ""),
            (script: "[1, 2]", expected: "1,2"),
            (script: "({})", expected: "[object Object]"),
            (script: "4n", expected: "4"),
            (script: "({ toString() { return 'custom' } })", expected: "custom"),
        ])
        func convert(script: String, expected: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(String.fromJSValue(value) == expected)
        }

        @Test("return nil and report JavaScript conversion exception", arguments: [
            "Symbol('value')",
            "({ toString() { throw new Error('toString failed') } })",
        ])
        func convertException(script: String) throws {
            let (context, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(String.fromJSValue(value) == nil)
            #expect(context.exception != nil)
        }

        @Test("convert nullish JavaScript value to nil", arguments: [
            "undefined",
            "null",
        ])
        func convertNullish(script: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(String.fromJSValue(value) == nil)
        }
    }
}
