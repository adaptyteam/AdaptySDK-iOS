//
//  JSValueRepresentableTests+Double.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

@testable import AdaptyUIBuilder
import Testing

extension JSValueRepresentableTests {
    struct DoubleTests {
        @Test("convert ordinary JavaScript value to Double", arguments: [
            (script: "true", expected: 1.0),
            (script: "false", expected: 0.0),
            (script: "4", expected: 4.0),
            (script: "-4.5", expected: -4.5),
            (script: #""""#, expected: 0.0),
            (script: #""4""#, expected: 4.0),
            (script: "[]", expected: 0.0),
            (script: "[4]", expected: 4.0),
            (script: "new Date(1000)", expected: 1000.0),
            (script: "4n", expected: 4.0),
        ])
        func convert(script: String, expected: Double) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Double.fromJSValue(value) == expected)
        }

        @Test("convert JavaScript value to NaN", arguments: [
            #""abc""#,
            "[1, 2]",
            "({})",
            "(() => 4)",
        ])
        func convertToNaN(script: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Double.fromJSValue(value)?.isNaN == true)
        }

        @Test("preserve non-finite JavaScript number", arguments: [
            (script: "Infinity", expected: Double.infinity),
            (script: "-Infinity", expected: -Double.infinity),
        ])
        func convertNonFinite(script: String, expected: Double) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Double.fromJSValue(value) == expected)
        }

        @Test("return NaN and report JavaScript conversion exception", arguments: [
            "Symbol('value')",
            "({ valueOf() { throw new Error('valueOf failed') } })",
        ])
        func convertException(script: String) throws {
            let (context, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Double.fromJSValue(value)?.isNaN == true)
            #expect(context.exception != nil)
        }

        @Test("convert nullish JavaScript value to nil", arguments: [
            "undefined",
            "null",
        ])
        func convertNullish(script: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(Double.fromJSValue(value) == nil)
        }
    }
}
