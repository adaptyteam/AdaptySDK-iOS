//
//  VC.RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package extension VC {
    struct RichText: Sendable, Hashable {
        package let items: [Item]
        package let fallback: [Item]?
    }
}

package extension VC.RichText {
    static let empty: Self = .init(items: [], fallback: nil)
    var isEmpty: Bool { items.isEmpty }

//    @inlinable
//    func items(with attributes: Attributes?) {
//        guard let attributes, !items.isEmpty else { return items }
//    }
//
//    @inlinable
//    func fallback(with attributes: Attributes?) {
//        guard let attributes, let fallback = fallback, !fallback.isEmpty else { return fallback }
//    }
//
//
//    private func convert(
//        defaultTextAttributes: Schema.TextAttributes?
//    ) -> [VC.RichText.Item] {
//        items.compactMap { item in
//            switch item {
//            case let .text(value, attributes):
//                .text(value, attributes.add(defaultTextAttributes).convert(localizer))
//            case let .tag(value, attributes):
//                .tag(value, attributes.add(defaultTextAttributes).convert(localizer))
//            case let .image(assetId, attributes):
//                .image(try? localizer.imageData(assetId), attributes.add(defaultTextAttributes).convert(localizer))
//            default:
//                nil
//            }
//        }
//    }
}
