//
//  JSValueRepresentableTests+Optional.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

@testable import AdaptyUIBuilder
import JavaScriptCore
import Testing

extension JSValueRepresentableTests {
    struct OptionalJSValueTests {
        @Test("return nil for absent JSValue")
        func convertNone() {
            #expect(Double.fromJSValue(nil as JSValue?) == nil)
        }

        @Test("forward present JSValue to concrete converter")
        func convertSome() throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue("4")
            #expect(Double.fromJSValue(value as JSValue?) == 4)
        }
    }
}
