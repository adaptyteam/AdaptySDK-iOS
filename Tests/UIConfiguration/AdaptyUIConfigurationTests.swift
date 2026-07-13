//
//  AdaptyUIConfigurationTests.swift
//  AdaptyTest
//
//  Created by Aleksei Valiano on 06.02.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(.tags(.logic))
struct AdaptyUIConfigurationTests {}

private extension AdaptyUIConfigurationTests {
    @Test("localization flattens element tree into pool")
    func localizeFlattensElementTreeIntoPool() throws {
        let schema = try AdaptyUISchema(from: """
        {
          "format": "4.8.0",
          "screens": {
            "main": {
              "content": {
                "type": "v_stack",
                "content": [
                  {
                    "type": "text",
                    "string_id": "title"
                  },
                  {
                    "type": "button",
                    "action": [],
                    "content": {
                      "type": "text",
                      "string_id": "button"
                    }
                  }
                ]
              }
            }
          },
          "navigators": {
            "default": {
              "order": 0,
              "content": {
                "type": "screen_holder"
              }
            }
          }
        }
        """)

        let configuration = try schema.extractUIConfiguration(
            id: "test",
            envoriment: .test
        )

        let screen = try #require(configuration.screens["main"])
        #expect(screen.poolElements.count == 4)
        #expect(screen.content == 3)

        guard case let .stack(stack, _) = screen.poolElements[screen.content] else {
            Issue.record("Expected root element to be a stack")
            return
        }
        #expect(stack.items == [.element(0), .element(2)])

        guard case let .button(button, _) = screen.poolElements[2] else {
            Issue.record("Expected third pool element to be a button")
            return
        }
        #expect(button.content == 1)

        let navigator = try #require(configuration.navigators["default"])
        #expect(navigator.poolElements == [.screenHolder])
        #expect(navigator.content == 0)
    }
}

private extension VC.EnvironmentConstants {
    static let test = Self(
        sdkVersion: "test",
        osName: "test",
        osVersion: "test",
        deviceModel: "test",
        appBundleId: nil,
        appVersion: nil,
        appBuild: nil,
        appCurrentLocale: nil,
        userLocales: [],
        userUses24HourClock: true
    )
}
