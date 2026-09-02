//
//  JSValueRepresentableTests+AssetIdentifierOrValue.swift
//  AdaptyTests
//
//  Created by Codex on 02.09.2026.
//

@testable import AdaptyUIBuilder
import Testing

extension JSValueRepresentableTests {
    struct AssetIdentifierOrValueTests {
        @Test("convert color string to color", arguments: [
            (script: "\"#112233\"", expected: UInt64(0x112233FF)),
            (script: "\"#11223344\"", expected: UInt64(0x11223344)),
        ])
        func convertColor(script: String, expected: UInt64) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            guard case let .color(color) = VC.AssetIdentifierOrValue.fromJSValue(value) else {
                Issue.record("Expected color for \(script)")
                return
            }
            #expect(color.data == expected)
        }

        @Test("convert other JavaScript value to asset identifier", arguments: [
            (script: #""asset-id""#, expected: "asset-id"),
            (script: #""""#, expected: ""),
            (script: "4", expected: "4"),
            (script: "true", expected: "true"),
            (script: "({})", expected: "[object Object]"),
        ])
        func convertAssetIdentifier(script: String, expected: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            guard case let .assetId(assetId) = VC.AssetIdentifierOrValue.fromJSValue(value) else {
                Issue.record("Expected asset identifier for \(script)")
                return
            }
            #expect(assetId == expected)
        }

        @Test("return nil and report JavaScript conversion exception", arguments: [
            "Symbol('value')",
            "({ toString() { throw new Error('toString failed') } })",
        ])
        func convertException(script: String) throws {
            let (context, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(VC.AssetIdentifierOrValue.fromJSValue(value) == nil)
            #expect(context.exception != nil)
        }

        @Test("convert nullish JavaScript value to nil", arguments: [
            "undefined",
            "null",
        ])
        func convertNullish(script: String) throws {
            let (_, value) = try JSValueRepresentableTests.evaluateJSValue(script)
            #expect(VC.AssetIdentifierOrValue.fromJSValue(value) == nil)
        }
    }
}
