//
//  CustomAssetsDecodingTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

import SwiftUI
import Testing
@testable import AdaptyPlugin
@testable import AdaptyUIBuilder

struct CustomAssetsDecodingTests {
    @Test("a custom color asset keeps the color the wrapper sent")
    func colorKeepsItsValue() throws {
        let asset = try Json(##"""
        {
            "id": "custom_color",
            "type": "color",
            "value": "#FF8000CC"
        }
        """##).decode(AdaptyUICustomAsset.Identifiable.self)

        guard case .asset(.color(.swiftUIColor(let color))) = asset.value else {
            Issue.record("Expected a custom color asset, got \(asset.value)")
            return
        }

        #expect(asset.id == "custom_color")
        #expect(color == Color(
            .sRGB,
            red: 1.0,
            green: 128.0 / 255.0,
            blue: 0.0,
            opacity: 204.0 / 255.0
        ))
    }

    @Test("a custom linear gradient keeps its stops and direction")
    func linearGradientKeepsItsValue() throws {
        let asset = try Json(##"""
        {
            "id": "custom_gradient",
            "type": "linear-gradient",
            "values": [
                { "color": "#FF0000FF", "p": 0.0 },
                { "color": "#0000FFFF", "p": 1.0 }
            ],
            "points": { "x0": 0.0, "y0": 0.0, "x1": 1.0, "y1": 0.0 }
        }
        """##).decode(AdaptyUICustomAsset.Identifiable.self)

        guard case .asset(.gradient(.linear(let gradient, let startPoint, let endPoint))) = asset.value else {
            Issue.record("Expected a custom linear gradient asset, got \(asset.value)")
            return
        }

        #expect(asset.id == "custom_gradient")
        #expect(gradient == Gradient(stops: [
            .init(color: Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0), location: 0.0),
            .init(color: Color(.sRGB, red: 0.0, green: 0.0, blue: 1.0, opacity: 1.0), location: 1.0),
        ]))
        #expect(startPoint == UnitPoint(x: 0.0, y: 0.0))
        #expect(endPoint == UnitPoint(x: 1.0, y: 0.0))
    }
}

#endif
