//
//  JSValueRepresentableTests.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

import JavaScriptCore
import Testing

@Suite(.tags(.logic))
struct JSValueRepresentableTests {
    static func evaluateJSValue(_ script: String) throws -> (JSContext, JSValue) {
        let context = try #require(JSContext())
        let value = try #require(context.evaluateScript(script))
        context.exception = nil
        return (context, value)
    }
}
