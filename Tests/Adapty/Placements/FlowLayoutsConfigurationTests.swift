//
//  FlowLayoutsConfigurationTests.swift
//  AdaptyTests
//

@testable import Adapty
import Foundation
import Testing

@Suite("Flow layouts configuration localization", .tags(.codable))
struct FlowLayoutsConfigurationTests {
    @Test("ui_schema locales decode into the localization source", arguments: [
        (fields: "", locales: nil, default: nil),
        // default_locale counts only together with locales
        (fields: #""default_locale": "fr","#, locales: nil, default: nil),
        (fields: #""locales": [],"#, locales: [], default: nil),
        // default_locale alone is still an available locale once locales is present
        (fields: #""locales": [], "default_locale": "fr","#, locales: [], default: "fr"),
        (fields: #""locales": ["fr"], "default_locale": "de","#, locales: ["fr"], default: "de"),
    ] as [(fields: String, locales: [String]?, default: String?)])
    func decode(fields: String, locales: [String]?, defaultLocale: String?) throws {
        let localization = try Self.decode(Self.json(fields)).localization
        #expect(localization?.locales == locales)
        #expect(localization?.defaultLocale == defaultLocale)
    }

    @Test("Encoding keeps the localization source", arguments: [
        "",
        #""locales": [],"#,
        #""locales": ["fr"], "default_locale": "de","#,
    ])
    func roundTrip(fields: String) throws {
        let original = try Self.decode(Self.json(fields))
        let decoded = try Self.decode(JSONEncoder().encode(original))
        #expect(decoded.localization?.locales == original.localization?.locales)
        #expect(decoded.localization?.defaultLocale == original.localization?.defaultLocale)
    }
}

private extension FlowLayoutsConfigurationTests {
    static func json(_ fields: String) -> Data {
        Data("""
        {
          "flow_version_id": "v1",
          "ui_schema": {
            \(fields)
            "layouts": [{ "flow_layout_id": "l1" }],
            "grids": [{ "cells": [0] }]
          }
        }
        """.utf8)
    }

    static func decode(_ data: Data) throws -> AdaptyFlow.LayoutsConfiguration {
        try JSONDecoder().decode(AdaptyFlow.LayoutsConfiguration.self, from: data)
    }
}
