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
    let cache: AdaptyUIAssetCache
    
    private var cancellables = Set<AnyCancellable>()

    package init(
        assetsResolver: AdaptyUIAssetsResolver,
        stateViewModel: AdaptyUIStateViewModel
    ) {
        self.assetsResolver = assetsResolver
        cache = AdaptyUIAssetCache(
            state: stateViewModel.state,
            customAssetsResolver: assetsResolver
        )

        stateViewModel.state.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func resolvedAsset(
        _ ref: AdaptyUIConfiguration.AssetReference?,
        mode: VC.Mode
    ) -> AdaptyUIResolvedAsset {
        cache.cachedAsset(ref, mode: mode).value
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
