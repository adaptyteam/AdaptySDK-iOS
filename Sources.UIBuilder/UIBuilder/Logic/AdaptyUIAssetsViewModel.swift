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
    let assetsResolver: AdaptyUIAssetsResolver
    let cache: AdaptyUIAssetsCache

    private var cancellables = Set<AnyCancellable>()

    package init(
        assetsResolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) {
        self.assetsResolver = assetsResolver
        cache = AdaptyUIAssetsCache(
            state: stateViewModel.state,
            customAssetsResolver: assetsResolver
        )
        _state = stateViewModel.state

        stateViewModel.state.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func resolvedAsset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode
    ) -> AdaptyUICachedAsset {
        cache.cachedAsset(ref, mode: mode)
    }

    // MARK: - Strings Assets Logic

    private let _state: VS // TODO: x remove

    enum ProductInfoContainer {
        case notApplicable
        case notFound
        case found(ProductResolver)
    }

    func resolvedText(
        _ ref: VC.StringReference,
        defaultAttributes: VC.RichText.Attributes?
    ) -> (VC.RichText, ProductInfoContainer) {
        switch ref {
        case let .stringId(stringId):
            let text = try? _state.richText(
                stringId,
                defaultAttributes: defaultAttributes
            )

            return (text ?? .empty, .notApplicable)
        case let .variable(variable):
            if let text = try? _state.getValue(
                String.self,
                variable: variable,
                screenInstance: fakeScreenInstance
            ) {
                let text = VC.RichText(
                    items: [.text(text, defaultAttributes)],
                    fallback: nil
                )

                return (text, .notApplicable)
            } else {
                return (.empty, .notApplicable)
            }
        case let .product(product):
            switch product {
            case let .id(productId, sufix):
                let text = try? _state.richText(
                    adaptyProductId: productId,
                    byPaymentMode: nil, // TODO: x use productsInfoProvider
                    suffix: sufix,
                    defaultAttributes: defaultAttributes
                )

                return (text ?? .empty, .notApplicable)
            case let .variable(variable, sufix):
                guard let productId = try? _state.getValue(
                    String.self,
                    variable: variable,
                    screenInstance: fakeScreenInstance
                ) else {
                    return (.empty, .notApplicable)
                }

                let text = try? _state.richText(
                    adaptyProductId: productId,
                    byPaymentMode: nil, // TODO: x use productsInfoProvider
                    suffix: sufix,
                    defaultAttributes: defaultAttributes
                )

                return (text ?? .empty, .notApplicable)
            }
        }
    }

    // MARK: - Video Player Logic

    @Published var playerStates = [String: AdaptyUIVideoPlayerManager.PlayerState]()
    @Published var playerManagers = [String: AdaptyUIVideoPlayerManager]()

    func getOrCreatePlayerManager(
        for video: AdaptyUIResolvedVideoAsset,
        loop: Bool,
        id: String
    ) -> AdaptyUIVideoPlayerManager {
        if let manager = playerManagers[id] {
            return manager
        }

        let manager = AdaptyUIVideoPlayerManager(
            video: video,
            loop: loop
        ) { [weak self] state in
            DispatchQueue.main.async { [weak self] in
                self?.playerStates[id] = state
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.playerManagers[id] = manager
            self?.playerStates[id] = .loading
        }

        return manager
    }

    func dismissPlayerManager(id: String) {
        playerManagers.removeValue(forKey: id)
    }
}

#endif
