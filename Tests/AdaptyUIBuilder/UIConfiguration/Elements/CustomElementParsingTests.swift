//
//  CustomElementParsingTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 26.08.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Custom Element"),
    .feature("Custom Element Parsing"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit),
    .tags(.codable)
)
enum CustomElementTests {
    @Suite(
        "Custom Element Parsing",
        .story("Custom Element Parsing")
    )
    struct CustomElementParsingTests {
        /// A minimal custom element is decoded with its required identity. Optional payload and common properties remain absent.
        @Test("Minimal custom element preserves its identity")
        func minimalCustomElementPreservesIdentity() throws {
            let (custom, properties) = try CustomElementTests.custom(content: """
            {
              "type": "custom",
              "custom_id": "hero",
              "custom_type": "chart"
            }
            """)

            #expect(custom.id == "hero")
            #expect(custom.type == "chart")
            #expect(custom.assets == nil)
            #expect(custom.strings == nil)
            #expect(custom.bindings == nil)
            #expect(custom.properties == nil)
            #expect(properties == nil)
        }

        /// A custom element is decoded without valid string identity fields. Schema decoding rejects each configuration.
        @Test("Custom identity fields are required strings", arguments: [
            ##"{"type":"custom","custom_type":"chart"}"##,
            ##"{"type":"custom","custom_id":"hero"}"##,
            ##"{"type":"custom","custom_id":1,"custom_type":"chart"}"##,
            ##"{"type":"custom","custom_id":"hero","custom_type":false}"##,
        ])
        func customIdentityFieldsAreRequiredStrings(content: String) {
            #expect(throws: (any Error).self) {
                try CustomElementTests.screen(content: content)
            }
        }

        /// A custom element is decoded with empty payload maps and common element properties. Both payload and shared properties are preserved.
        @Test("Common properties and empty maps are preserved")
        func commonPropertiesAndEmptyMapsArePreserved() throws {
            let (custom, properties) = try CustomElementTests.custom(content: """
            {
              "type": "custom",
              "custom_id": "hero",
              "custom_type": "chart",
              "assets": {},
              "strings": {},
              "bindings": {},
              "properties": {},
              "opacity": 0.5,
              "focus_id": "hero-focus",
              "ui_enabled": { "var": "state.enabled" }
            }
            """)

            #expect(custom.assets?.isEmpty == true)
            #expect(custom.strings?.isEmpty == true)
            #expect(custom.bindings?.isEmpty == true)
            let customProperties = try #require(custom.properties)
            #expect(customProperties.isEmpty)
            #expect(properties?.opacity == 0.5)
            #expect(properties?.focusId == "hero-focus")
            #expect(properties?.interactionEnabled?.path == ["state", "enabled"])
        }

        /// A custom element contains non-null values outside the typed map contracts. Schema decoding rejects each configuration.
        @Test("Typed maps reject invalid non-null values", arguments: [
            ##""strings":[]"##,
            ##""bindings":"value""##,
            ##""assets":{"hero":42}"##,
            ##""strings":{"title":false}"##,
            ##""bindings":{"value":{"setter":"setValue"}}"##,
        ])
        func typedMapsRejectInvalidValues(field: String) {
            #expect(throws: (any Error).self) {
                try CustomElementTests.screen(content: ##"{"type":"custom","custom_id":"hero","custom_type":"chart",\##(field)}"##)
            }
        }

        /// A custom element is decoded with typed references and direct or nested setters. Existing reference metadata is preserved.
        @Test("Typed references preserve direct and nested setters")
        func typedReferencesPreserveDirectAndNestedSetters() throws {
            let (custom, _) = try CustomElementTests.custom(content: """
            {
              "type": "custom",
              "custom_id": "hero",
              "custom_type": "chart",
              "assets": {
                "image": "hero_image",
                "tint": "#FF0000FF",
                "dynamic": {
                  "var": "assets.hero",
                  "setter": "setHeroAsset"
                }
              },
              "strings": {
                "title": "hero_title",
                "dynamic": {
                  "var": "copy.title",
                  "setter": "setTitle"
                },
                "tagged": {
                  "string_id": "welcome",
                  "name": {
                    "var": "user.name",
                    "setter": "setUserName"
                  }
                },
                "product": {
                  "product": {
                    "var": "product.id",
                    "setter": "setProductId"
                  },
                  "suffix": "price"
                }
              },
              "bindings": {
                "value": {
                  "var": "state.value",
                  "setter": "setValue",
                  "scope": "global",
                  "converter": "is_equal",
                  "converter_params": 1
                }
              }
            }
            """)

            guard case let .assetId(assetId)? = custom.assets?["image"] else {
                Issue.record("Expected an asset identifier")
                return
            }
            #expect(assetId == "hero_image")

            guard case .color? = custom.assets?["tint"] else {
                Issue.record("Expected a color")
                return
            }

            guard case let .variable(assetVariable)? = custom.assets?["dynamic"] else {
                Issue.record("Expected an asset binding")
                return
            }
            #expect(assetVariable.setter == "setHeroAsset")

            guard case let .stringId(stringId, nil)? = custom.strings?["title"] else {
                Issue.record("Expected a localization string identifier")
                return
            }
            #expect(stringId == "hero_title")

            guard case let .variable(stringVariable)? = custom.strings?["dynamic"] else {
                Issue.record("Expected a localization binding")
                return
            }
            #expect(stringVariable.setter == "setTitle")

            guard case let .stringId(taggedId, tags)? = custom.strings?["tagged"],
                  case let .variable(tagVariable)? = tags?["name"] else {
                Issue.record("Expected a localization tag binding")
                return
            }
            #expect(taggedId == "welcome")
            #expect(tagVariable.setter == "setUserName")

            guard case let .product(.variable(productVariable, suffix))? = custom.strings?["product"] else {
                Issue.record("Expected a product localization binding")
                return
            }
            #expect(productVariable.setter == "setProductId")
            #expect(suffix == "price")

            let binding = try #require(custom.bindings?["value"])
            #expect(binding.path == ["state", "value"])
            #expect(binding.setter == "setValue")
            #expect(binding.scope == .global)
            #expect(binding.converter != nil)
        }

        /// Custom elements are decoded with absent and empty properties. The UI configuration preserves the difference between both forms.
        @Test("Absent properties differs from an empty object")
        func absentPropertiesDiffersFromEmptyObject() throws {
            let (absent, _) = try CustomElementTests.custom(content: ##"{"type":"custom","custom_id":"absent","custom_type":"raw"}"##)
            let (empty, _) = try CustomElementTests.custom(content: ##"{"type":"custom","custom_id":"empty","custom_type":"raw","properties":{}}"##)

            #expect(absent.properties == nil)
            let emptyObject = try #require(empty.properties)
            #expect(emptyObject.isEmpty)
        }

        /// A custom element is decoded with recursive raw JSON properties. Scalar, array, object, and special-looking values remain unchanged.
        @Test("Properties preserves recursive raw JSON")
        func propertiesPreservesRecursiveRawJSON() throws {
            let (custom, _) = try CustomElementTests.custom(content: """
            {
              "type": "custom",
              "custom_id": "raw",
              "custom_type": "payload",
              "properties": {
                "null": null,
                "boolean": true,
                "integer": 42,
                "number": 1.5,
                "string": "value",
                "array": [null, false, 2, 3.5, "item"],
                "special": {
                  "var": "state.value",
                  "setter": "setValue",
                  "string_id": "title",
                  "product": "product_id",
                  "func": "submit"
                }
              }
            }
            """)

            let object = try #require(custom.properties)

            #expect(object["null"] is NSNull)
            #expect(object["boolean"] as? Bool == true)
            #expect(object["integer"] as? Int == 42)
            #expect(object["number"] as? Double == 1.5)
            #expect(object["string"] as? String == "value")

            let array = try #require(object["array"] as? [any Sendable])
            #expect(array.count == 5)
            #expect(array[0] is NSNull)
            #expect(array[1] as? Bool == false)
            #expect(array[2] as? Int == 2)
            #expect(array[3] as? Double == 3.5)
            #expect(array[4] as? String == "item")

            let special = try #require(object["special"] as? [String: any Sendable])
            #expect(special["var"] as? String == "state.value")
            #expect(special["setter"] as? String == "setValue")
            #expect(special["string_id"] as? String == "title")
            #expect(special["product"] as? String == "product_id")
            #expect(special["func"] as? String == "submit")
        }
    }
}

private extension CustomElementTests {
    static func custom(content: String) throws -> (custom: VC.CustomElement, properties: VC.Element.Properties?) {
        let screen = try screen(content: content)
        guard case let .custom(custom, properties) = screen.poolElements[screen.content] else {
            Issue.record("Expected root element to be a CustomElement")
            throw TestError.expectedCustomElement
        }

        return (custom, properties)
    }

    static func screen(content: String) throws -> VC.Screen {
        let schema = try AdaptyUISchema(
            from: """
            {
              "format": "5.1.0",
              "screens": {
                "main": {
                  "content": \(content)
                }
              }
            }
            """,
            configuration: .init(device: .phone)
        )

        let configuration = try schema.extractUIConfiguration(
            id: "custom-element-test",
            withLocaleId: "en",
            envoriment: .customElementTest
        )

        return try #require(configuration.screens["main"])
    }

    enum TestError: Error {
        case expectedCustomElement
    }
}

private extension VC.EnvironmentConstants {
    static let customElementTest = Self(
        sdkVersion: "test",
        osName: "test",
        osVersion: "test",
        deviceModel: "test",
        appBundleId: nil,
        appVersion: nil,
        appBuild: nil,
        appCurrentLocale: nil,
        userLocales: [],
        userUses24HourClock: true,
        flow: .init(
            placementId: "test",
            variationId: "test",
            abTestName: "test",
            name: "test",
            products: []
        )
    )
}
