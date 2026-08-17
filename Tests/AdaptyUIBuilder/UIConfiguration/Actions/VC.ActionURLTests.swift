//
//  VC.ActionURLTests.swift
//  AdaptyTests
//
//  Created by Codex on 16.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUIConfigurationTests {
    struct VCActionURLTests {}
}

private extension AdaptyUIConfigurationTests.VCActionURLTests {
    typealias Action = VC.Action

    @Test("asURL encodes action without params")
    func encodesActionWithoutParams() throws {
        let action = Action(
            path: ["close", "paywall"],
            params: nil,
            scope: .global
        )

        let url = try #require(action.asURL)

        #expect(url.absoluteString == "sdk://global.action/close/paywall")
    }

    @Test("asURL encodes sorted nested params")
    func encodesSortedNestedParams() throws {
        let action = Action(
            path: ["submit"],
            params: [
                "message": VC.AnyValue("hello"),
                "payload": VC.AnyValue([
                    "enabled": VC.AnyValue(true),
                    "name": VC.AnyValue("alex"),
                    "ratio": VC.AnyValue(1.5),
                    "empty": VC.AnyValue(String?.none),
                ]),
            ],
            scope: .screen
        )

        let url = try #require(action.asURL)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(components.scheme == "sdk")
        #expect(components.host == "screen.action")
        #expect(components.path == "/submit")
        #expect(components.queryItems == [
            URLQueryItem(name: "message_s", value: "hello"),
            URLQueryItem(name: "payload.empty", value: nil),
            URLQueryItem(name: "payload.enabled_b", value: "true"),
            URLQueryItem(name: "payload.name_s", value: "alex"),
            URLQueryItem(name: "payload.ratio_d", value: "1.5"),
        ])
    }

    @Test("init url decodes nested params")
    func decodesNestedParams() throws {
        let url = try #require(
            URL(string: "sdk://screen.action/submit?message_s=hello&payload.empty&payload.enabled_b=true&payload.name_s=alex&payload.ratio_d=1.5")
        )

        let action = try Action(url: url)

        #expect(action.scope == .screen)
        #expect(action.path == ["submit"])

        let params = try #require(action.params)
        try expectEqual(params["message"], VC.AnyValue("hello"))

        let payload = try #require(params["payload"])
        let payloadObject = try #require(payload.wrapped.asObject)
        try expectEqual(payloadObject["enabled"].map(VC.AnyValue.init), VC.AnyValue(true))
        try expectEqual(payloadObject["name"].map(VC.AnyValue.init), VC.AnyValue("alex"))
        try expectEqual(payloadObject["ratio"].map(VC.AnyValue.init), VC.AnyValue(1.5))
        let empty = try #require(payloadObject["empty"])
        #expect(empty.isNil)
    }

    @Test("action url round-trip preserves string bool nil object params")
    func roundTripURL() throws {
        let action = Action(
            path: ["track", "event"],
            params: [
                "flag": VC.AnyValue(false),
                "meta": VC.AnyValue([
                    "comment": VC.AnyValue("ok"),
                    "value": VC.AnyValue(3.25),
                    "missing": VC.AnyValue(String?.none),
                ]),
            ],
            scope: .global
        )

        let url = try #require(action.asURL)
        let decoded = try Action(url: url)

        #expect(decoded.scope == action.scope)
        #expect(decoded.path == action.path)

        let decodedParams = try #require(decoded.params)
        let originalParams = try #require(action.params)
        try expectEqual(decodedParams, originalParams)
    }

    @Test("init url throws for wrong scheme")
    func wrongSchemeThrows() throws {
        let url = try #require(URL(string: "https://screen.action/submit"))

        #expect(throws: DecodingError.self) {
            _ = try Action(url: url)
        }
    }

    @Test("init url throws for empty path")
    func emptyPathThrows() throws {
        let url = try #require(URL(string: "sdk://screen.action"))

        #expect(throws: DecodingError.self) {
            _ = try Action(url: url)
        }
    }

    private func expectEqual(_ lhs: [String: VC.AnyValue], _ rhs: [String: VC.AnyValue]) throws {
        #expect(lhs.count == rhs.count)
        #expect(Set(lhs.keys) == Set(rhs.keys))

        for key in lhs.keys {
            try expectEqual(lhs[key], rhs[key])
        }
    }

    private func expectEqual(_ lhs: VC.AnyValue?, _ rhs: VC.AnyValue?) throws {
        switch (lhs, rhs) {
        case let (.some(lhs), .some(rhs)):
            try expectEqual(lhs, rhs)
        case (.none, .none):
            break
        default:
            Issue.record("Values are different: \(String(describing: lhs)) != \(String(describing: rhs))")
        }
    }

    private func expectEqual(_ lhs: VC.AnyValue, _ rhs: VC.AnyValue) throws {
        if lhs.wrapped.isNil || rhs.wrapped.isNil {
            #expect(lhs.wrapped.isNil == rhs.wrapped.isNil)
            return
        }

        if let lhs = lhs.wrapped as? String, let rhs = rhs.wrapped as? String {
            #expect(lhs == rhs)
            return
        }
        if let lhs = lhs.wrapped as? Bool, let rhs = rhs.wrapped as? Bool {
            #expect(lhs == rhs)
            return
        }
        if let lhs = lhs.wrapped as? Double, let rhs = rhs.wrapped as? Double {
            #expect(lhs == rhs)
            return
        }
        if let lhs = lhs.wrapped.asObject, let rhs = rhs.wrapped.asObject {
            try expectEqual(lhs.mapValues(VC.AnyValue.init), rhs.mapValues(VC.AnyValue.init))
            return
        }

        #expect(lhs == rhs)
    }
}

