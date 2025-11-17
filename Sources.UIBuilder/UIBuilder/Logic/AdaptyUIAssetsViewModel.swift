//
//  AdaptyUIAssetsViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit)

import UIKit

@MainActor
package class AdaptyUIAssetsViewModel: ObservableObject {
    let assetsResolver: AdaptyUIAssetsResolver

    package init(
        assetsResolver: AdaptyUIAssetsResolver
    ) {
        self.assetsResolver = assetsResolver
    }

    @Published var playerStates = [String: AdaptyUIVideoPlayerManager.PlayerState]()
    @Published var playerManagers = [String: AdaptyUIVideoPlayerManager]()

    func getOrCreatePlayerManager(
        for video: VC.VideoData,
        loop: Bool,
        id: String
    ) -> AdaptyUIVideoPlayerManager {
        if let manager = playerManagers[id] {
            return manager
        }

        let manager = AdaptyUIVideoPlayerManager(
            video: video,
            loop: loop,
            assetsResolver: assetsResolver
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
