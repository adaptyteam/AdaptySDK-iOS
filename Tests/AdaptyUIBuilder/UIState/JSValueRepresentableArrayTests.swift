//
//  JSValueRepresentableArrayTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite(
    "JS Array Reading",
    .component("AdaptyUIBuilder"),
    .epic("JavaScript Bridge"),
    .feature("Variable Values"),
    .risk(.high),
    .owner("Aleksei Valiano"),
    .layer(.unit)
)
@MainActor
struct JSValueRepresentableArrayTests {
    /// Supported array metatypes pass the public reader's runtime protocol check.
    @Test("Arrays of supported types can be requested")
    func supportedTypes() {
        let supported: [Any.Type] = [[Bool].self, [Int32].self, [UInt32].self, [Double].self, [String].self, [[Double]].self]
        for type in supported {
            #expect(type is any JSValueRepresentable.Type)
        }
        let unsupported: [Any.Type] = [[Any].self, [Date].self]
        for type in unsupported {
            #expect(!(type is any JSValueRepresentable.Type))
        }
    }

    /// Every supported scalar type can be read from an array with the same order.
    @Test("Scalar arrays preserve values and order")
    func scalarArrays() throws {
        let context = try #require(JSContext())
        #expect([String].fromJSValue(context.evaluateScript(#"["one", "", "Привет 🐈"]"#)) == ["one", "", "Привет 🐈"])
        #expect([Double].fromJSValue(context.evaluateScript("[1.5, -2, 0]")) == [1.5, -2, 0])
        #expect([Bool].fromJSValue(context.evaluateScript("[true, false, true]")) == [true, false, true])
        #expect([Int32].fromJSValue(context.evaluateScript("[-2147483648, 42, 2147483647]")) == [.min, 42, .max])
        #expect([UInt32].fromJSValue(context.evaluateScript("[0, 42, 4294967295]")) == [0, 42, .max])
    }

    /// Empty arrays are successful reads, and typed nested arrays convert recursively.
    @Test("Empty and nested arrays are supported")
    func nestedArrays() throws {
        let context = try #require(JSContext())
        #expect([String].fromJSValue(context.evaluateScript("[]")) == [])
        #expect([Double].fromJSValue(context.evaluateScript("[]")) == [])
        #expect([[Double]].fromJSValue(context.evaluateScript("[[1, 2.5], [], [-3]]")) == [[1, 2.5], [], [-3]])
        #expect([[String]].fromJSValue(context.evaluateScript(#"[["a"], [], ["b", "c"]]"#)) == [["a"], [], ["b", "c"]])
    }

    /// Element conversion follows the existing scalar converters, including their coercion rules.
    @Test("Arrays use the existing element conversion")
    func elementConversion() throws {
        let context = try #require(JSContext())
        #expect([String].fromJSValue(context.evaluateScript("[42, true]")) == ["42", "true"])
        #expect([Double].fromJSValue(context.evaluateScript(#"["1.5", true, false]"#)) == [1.5, 1, 0])
    }

    /// Objects with indexed properties are not arrays and must not be accepted as such.
    @Test("Non-array values return nil", arguments: ["null", "undefined", "42", "true", "'text'", "({})", "({0: 'value', length: 1})"])
    func nonArrays(script: String) throws {
        let context = try #require(JSContext())
        let value = try #require(context.evaluateScript(script))
        #expect([String].fromJSValue(value) == nil)
        #expect([Double].fromJSValue(value) == nil)
    }

    /// A missing or null element fails the whole read instead of shortening the result.
    @Test("Unconvertible elements do not shift indices", arguments: ["[1, null, 3]", "[1, undefined, 3]", "[1, , 3]"])
    func unconvertibleElements(script: String) throws {
        let context = try #require(JSContext())
        let value = try #require(context.evaluateScript(script))
        #expect([String].fromJSValue(value) == nil)
        #expect([Double].fromJSValue(value) == nil)
        #expect([[Double]].fromJSValue(context.evaluateScript("[[1], null, [3]]")) == nil)
        #expect([[Double]].fromJSValue(context.evaluateScript("[[1], 2, [3]]")) == nil)
    }

    /// Reading individual JSValues avoids recursively bridging a cyclic array into Foundation.
    @Test("Cyclic arrays with an incompatible nested shape return nil")
    func cyclicArray() throws {
        let context = try #require(JSContext())
        let value = try #require(context.evaluateScript("(() => { const a = []; a.push(a, null); return a; })()"))
        #expect([[Double]].fromJSValue(value) == nil)
    }

    /// A throwing array accessor produces no element and fails the read without a native crash.
    @Test("Throwing element getters return nil")
    func throwingGetter() throws {
        let context = try #require(JSContext())
        let value = try #require(context.evaluateScript("Object.defineProperty([1], '0', { get() { throw new Error('boom'); } })"))
        #expect([Double].fromJSValue(value) == nil)
        #expect(context.exception != nil)
    }
}
