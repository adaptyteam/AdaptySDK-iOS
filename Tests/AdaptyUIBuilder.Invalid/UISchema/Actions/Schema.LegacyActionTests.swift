//
//  Schema.LegacyActionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

extension SchemaTests {
    struct LegacyActionTests {
        typealias Value = Schema.Action

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                Value(
                    path: ["SDK", "openUrl"],
                    params: ["stringId": VC.Value("example_com")],
                    scope: .global
                ),
                Json(##"{"type":"open_url","url":"example_com"}"##)
            ),
            (
                Value(
                    path: ["SDK", "restorePurchases"],
                    params: nil,
                    scope: .global
                ),
                Json(##"{"type":"restore"}"##)
            ),
            (
                Value(path: ["SDK", "closeAll"],
                      params: nil,
                      scope: .global),
                Json(##"{"type":"close"}"##)
            ),
            (
                Value(
                    path: ["SDK", "userCustomAction"],
                    params: ["userCustomId": VC.Value("my_action")],
                    scope: .global
                ),
                Json(##"{"type":"custom","custom_id":"my_action"}"##)
            ),
//            (
//                Value(
//                    path: ["SDK", "webPurchasePaywall"],
//                    params: [
//                        "openIn": .string("browser_out_app"),
//                    ],
//                    scope: .global
//                ),
//                Json(##"{"type":"web_purchase_paywall"}"##)
//            ),
//            (
//                Value(
//                    path: ["SDK", "webPurchasePaywall"],
//                    params: [
//                        "openIn": .string("browser_in_app"),
//                    ],
//                    scope: .global
//                ),
//                Json(##"{"type":"web_purchase_paywall","open_in":"browser_in_app"}"##)
//            ),
            (
                Value(
                    path: ["SDK", "purchaseProduct"],
                    params: [
                        "productId": VC.Value("premium"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"purchase_product","product_id":"premium"}"##)
            ),
            (
                Value(
                    path: ["SDK", "webPurchaseProduct"],
                    params: [
                        "productId": VC.Value("premium"),
                        "openIn": VC.Value("browser_out_app"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"web_purchase_product","product_id":"premium"}"##)
            ),
            (
                Value(
                    path: ["SDK", "openScreen"],
                    params: [
                        "type": VC.Value("details"),
                        "instanceId": VC.Value("legacy-bottom-sheet"),
                        "navigatorId": VC.Value("legacy-bottom-sheet"),
                        "transitionId": VC.Value("on_appear"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"open_screen","screen_id":"details"}"##)
            ),
            (
                Value(
                    path: ["SDK", "closeScreen"],
                    params: [
                        "navigatorId": VC.Value("legacy-bottom-sheet"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"close_screen"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "selectProduct"],
                    params: [
                        "productId": VC.Value("prod1"),
                        "groupId": VC.Value("group_B"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"select_product","product_id":"prod1","group_id":"group_B"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "selectProduct"],
                    params: [
                        "productId": VC.Value("prod1"),
                        "groupId": VC.Value("group_A"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"select_product","product_id":"prod1"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "unselectProduct"],
                    params: [
                        "groupId": VC.Value("group_B"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"unselect_product","group_id":"group_B"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "unselectProduct"],
                    params: [
                        "groupId": VC.Value("group_A"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"unselect_product"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "purchaseSelectedProduct"],
                    params: [
                        "groupId": VC.Value("group_B"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"purchase_selected_product","group_id":"group_B"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "purchaseSelectedProduct"],
                    params: [
                        "groupId": VC.Value("group_A"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"purchase_selected_product"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "webPurchaseSelectedProduct"],
                    params: [
                        "groupId": VC.Value("group_B"),
                        "openIn": VC.Value("browser_out_app"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"web_purchase_selected_product","group_id":"group_B"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "webPurchaseSelectedProduct"],
                    params: [
                        "groupId": VC.Value("group_A"),
                        "openIn": VC.Value("browser_out_app"),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"web_purchase_selected_product"}"##)
            ),
            (
                Value(
                    path: ["Legacy", "switchSection"],
                    params: [
                        "sectionId": VC.Value("tabs"),
                        "index": VC.Value(1),
                    ],
                    scope: .global
                ),
                Json(##"{"type":"switch","section_id":"tabs","index":1}"##)
            ),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid action (legacy format)", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value) 
        }
    }
}

