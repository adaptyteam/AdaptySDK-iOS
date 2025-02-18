//
//  AdaptyAssetsViewModel.swift
//  Adapty
//
//  Created by Alexey Goncharov on 1/16/25.
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyAssetsResolver {
    func uiImage(for name: String) -> UIImage? {
        guard let asset = image(for: name) else { return nil }

        switch asset {
        case let .file(url):
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                return image
            } else {
                return nil
            }
        case .remote:
            return nil
        case let .image(value):
            return value
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package class AdaptyAssetsViewModel: ObservableObject {
    let eventsHandler: AdaptyEventsHandler
    let assetsResolver: AdaptyAssetsResolver

    package init(
        eventsHandler: AdaptyEventsHandler,
        assetsResolver: AdaptyAssetsResolver
    ) {
        self.eventsHandler = eventsHandler
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
            eventsHandler: eventsHandler,
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
