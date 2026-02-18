//
//  AdaptyUIAssetsViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 1/16/25.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

        if playerStates[id] == nil {
            playerStates[id] = .loading
        }

        let manager = AdaptyUIVideoPlayerManager(
            video: video,
            loop: loop,
            assetsResolver: assetsResolver
        ) { [weak self] state in
            Task { @MainActor [weak self] in
                self?.playerStates[id] = state
            }
        }

        playerManagers[id] = manager

        return manager
    }

    func dismissPlayerManager(id: String) {
        playerManagers.removeValue(forKey: id)
    }
}
