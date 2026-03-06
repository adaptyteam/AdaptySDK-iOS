//
//  AdaptyUIAssetsViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit)

import Combine
import SwiftUI
import UIKit

@MainActor
package class AdaptyUIAssetsViewModel: ObservableObject {
    let logId: String
    let assetsResolver: AdaptyUIAssetsResolver
    let cache: AdaptyUIAssetsCache
    let stateHolder: AdaptyUIStateHolder

    private var cancellables = Set<AnyCancellable>()

    package init(
        logId: String,
        assetsResolver: AdaptyUIAssetsResolver,
        stateHolder: AdaptyUIStateHolder
    ) {
        self.logId = logId
        self.assetsResolver = assetsResolver
        self.stateHolder = stateHolder
        cache = AdaptyUIAssetsCache(
            state: stateHolder.state,
            customAssetsResolver: assetsResolver
        )

        stateHolder.state.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func resolvedAsset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode,
        screen: VS.ScreenInstance
    ) -> AdaptyUICachedAsset {
        cache.cachedAsset(ref, mode: mode, screen: screen)
    }

    // MARK: - Strings Assets Logic

    enum ProductInfoContainer {
        case notApplicable
        case notFound
        case found(ProductResolver)
    }

    func resolvedText(
        _ ref: VC.StringReference,
        screen: VS.ScreenInstance
    ) -> (
        richText: VC.RichText,
        tagValues: [String: AdaptyUIConfiguration.StringReference.TagValue]?,
        productInfo: ProductInfoContainer
    ) {
        switch ref {
        case let .stringId(stringId, tagValues): // TODO: x need use tagValues
            let text = try? stateHolder.state.richText(stringId)
            return (
                richText: text ?? .empty,
                tagValues: tagValues,
                productInfo: .notApplicable
            )
        case let .variable(variable):
            if let stringId = try? stateHolder.state.getValue(
                String.self,
                variable: variable,
                screenInstance: screen
            ) {
                let text = try? stateHolder.state.richText(stringId)
                return (
                    richText: text ?? .empty,
                    tagValues: nil,
                    productInfo: .notApplicable
                )
            } else {
                return (
                    richText: .empty,
                    tagValues: nil,
                    productInfo: .notApplicable
                )
            }
        case let .product(product):
            switch product {
            case let .id(productId, sufix):
                let text = try? stateHolder.state.richText(
                    adaptyProductId: productId,
                    byPaymentMode: nil, // TODO: x use productsInfoProvider
                    suffix: sufix
                )
                return (
                    richText: text ?? .empty,
                    tagValues: nil,
                    productInfo: .notApplicable
                )
            case let .variable(variable, sufix):
                guard let productId = try? stateHolder.state.getValue(
                    String.self,
                    variable: variable,
                    screenInstance: screen
                ) else {
                    let text = try? stateHolder.state.richTextForNonSelectedProduct(suffix: sufix)
                    return (
                        richText: text ?? .empty,
                        tagValues: nil,
                        productInfo: .notApplicable
                    )
                }

                let text = try? stateHolder.state.richText(
                    adaptyProductId: productId,
                    byPaymentMode: nil, // TODO: x use productsInfoProvider
                    suffix: sufix
                )
                return (
                    richText: text ?? .empty,
                    tagValues: nil,
                    productInfo: .notApplicable
                )
            }
        }
    }

    // MARK: - Video Player Logic

    private var playerManagers = [VC.AssetReference: AdaptyUIVideoPlayerManager]()

    func getOrCreatePlayerManager(
        for video: AdaptyUIResolvedVideoAsset,
        assetRef: VC.AssetReference,
        loop: Bool
    ) -> AdaptyUIVideoPlayerManager {
        if let manager = playerManagers[assetRef] {
            return manager
        }

        let manager = AdaptyUIVideoPlayerManager(
            asset: video.asset,
            loop: loop
        )

        playerManagers[assetRef] = manager

        return manager
    }
}

#endif
