//
//  VC.Action+URL.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.05.2026.
//

import Foundation

extension VC.Action {
    private static let scheme = "sdk"
    private static let host = "action"

    var asURL: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host

        switch self {
        case let .openUrl(url, openIn):
            components.path = "/open_url"
            components.queryItems = [
                URLQueryItem(name: "url", value: url),
                URLQueryItem(name: "in", value: openIn.rawValue),
            ]
        case .restore:
            components.path = "/restore"
        case let .custom(id):
            components.path = "/custom"
            components.queryItems = [
                URLQueryItem(name: "id", value: id),
            ]
        case let .selectProduct(id, groupId):
            components.path = "/select_product"
            components.queryItems = [
                URLQueryItem(name: "id", value: id),
                URLQueryItem(name: "group", value: groupId),
            ]
        case let .purchaseProduct(id, .storeKit):
            components.path = "/purchase_product"
            components.queryItems = [
                URLQueryItem(name: "id", value: id),
            ]
        case let .purchaseProduct(id, .openWebPaywall(openIn)):
            components.path = "/web_purchase_product"
            components.queryItems = [
                URLQueryItem(name: "id", value: id),
                URLQueryItem(name: "in", value: openIn.rawValue),
            ]
        case let .unselectProduct(groupId):
            components.path = "/unselect_product"
            components.queryItems = [
                URLQueryItem(name: "group", value: groupId),
            ]
        case let .purchaseSelectedProduct(groupId, .storeKit):
            components.path = "/purchase_selected_product"
            components.queryItems = [
                URLQueryItem(name: "group", value: groupId),
            ]
        case let .purchaseSelectedProduct(groupId, .openWebPaywall(openIn)):
            components.path = "/web_purchase_selected_product"
            components.queryItems = [
                URLQueryItem(name: "group", value: groupId),
                URLQueryItem(name: "in", value: openIn.rawValue),
            ]
        case .close:
            components.path = "/close"
        case let .switchSection(id, index):
            components.path = "/switch_section"
            components.queryItems = [
                URLQueryItem(name: "id", value: id),
                URLQueryItem(name: "i", value: String(index)),
            ]
        case let .openScreen(id):
            components.path = "/open_screen"
            components.queryItems = [
                URLQueryItem(name: "id", value: id),
            ]
        case .closeScreen:
            components.path = "/close_screen"
        case let .openWebPaywall(openIn):
            components.path = "/open_web_paywall"
            components.queryItems = [
                URLQueryItem(name: "in", value: openIn.rawValue),
            ]
        }
        return components.url
    }

    init(
        url: URL
    ) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong url: \(url)"
                )
            )
        }

        guard components.scheme == Self.scheme else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong schema of url: \(url) use: \(Self.scheme)"
                )
            )
        }

        guard components.host == Self.host
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong host of url: \(url) use: \(Self.host)"
                )
            )
        }

        let queryItems = components.queryItems ?? []

        func optionalValue(_ key: String) -> String? {
            queryItems.first(where: { $0.name == key })?.value
        }

        func requiredValue(_ key: String) throws -> String {
            guard let value = optionalValue(key) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription: "missing required query item: \(key)"
                    )
                )
            }
            return value
        }

        func requiredIntValue(_ key: String) throws -> Int {
            let rawValue = try requiredValue(key)
            guard let integer = Int(rawValue) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription: "invalid query item: \(key), must be integer: \(rawValue)"
                    )
                )
            }
            return integer
        }

        func requiredWebOpenInValue(_ key: String) throws -> VC.WebOpenInParameter {
            let rawValue = try requiredValue(key)
            guard let openIn = VC.WebOpenInParameter(rawValue: rawValue) else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: [],
                        debugDescription: "invalid query item: \(key), value: \(rawValue)"
                    )
                )
            }
            return openIn
        }

        switch components.path {
        case "/open_url":
            self = try .openUrl(
                optionalValue("url"),
                openIn: requiredWebOpenInValue("in")
            )
        case "/restore":
            self = .restore
        case "/custom":
            self = try .custom(id: requiredValue("id"))
        case "/select_product":
            self = try .selectProduct(
                id: requiredValue("id"),
                groupId: requiredValue("group")
            )
        case "/purchase_product":
            self = try .purchaseProduct(
                id: requiredValue("id"),
                service: .storeKit
            )
        case "/web_purchase_product":
            self = try .purchaseProduct(
                id: requiredValue("id"),
                service: .openWebPaywall(openIn: requiredWebOpenInValue("in"))
            )
        case "/unselect_product":
            self = try .unselectProduct(groupId: requiredValue("group"))
        case "/purchase_selected_product":
            self = try .purchaseSelectedProduct(
                groupId: requiredValue("group"),
                service: .storeKit
            )
        case "/web_purchase_selected_product":
            self = try .purchaseSelectedProduct(
                groupId: requiredValue("group"),
                service: .openWebPaywall(openIn: requiredWebOpenInValue("in"))
            )
        case "/close":
            self = .close
        case "/switch_section":
            self = try .switchSection(
                id: requiredValue("id"),
                index: requiredIntValue("i")
            )
        case "/open_screen":
            self = try .openScreen(id: requiredValue("id"))
        case "/close_screen":
            self = .closeScreen
        case "/open_web_paywall":
            self = try .openWebPaywall(openIn: requiredWebOpenInValue("in"))
        case let path:
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "wrong action name in path of url: \(url)"
                )
            )
        }
    }
}

