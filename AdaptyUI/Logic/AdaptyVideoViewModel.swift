//
//  AdaptyVideoViewModel.swift
//
//
//  Created by Aleksey Goncharov on 15.08.2024.
//

#if canImport(UIKit)

import Adapty
import AVKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package class AdaptyVideoViewModel: ObservableObject {
    let eventsHandler: AdaptyEventsHandler

    package init(eventsHandler: AdaptyEventsHandler) {
        self.eventsHandler = eventsHandler
    }

    @Published var playerStates = [String: AdaptyUIVideoPlayerManager.PlayerState]()
    @Published var playerManagers = [String: AdaptyUIVideoPlayerManager]()

    func getOrCreatePlayerManager(
        for video: AdaptyUICore.VideoData,
        loop: Bool,
        id: String
    ) -> AdaptyUIVideoPlayerManager {
        if let manager =  playerManagers[id] {
            return manager
        }

        let manager = AdaptyUIVideoPlayerManager(
            video: video,
            loop: loop,
            eventsHandler: eventsHandler
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
class AdaptyUIVideoPlayerManager: NSObject, ObservableObject {
    enum PlayerState {
        case invalid

        case loading
        case ready
        case failed(String)

        var title: String {
            switch self {
            case .invalid: "Invalid"
            case .loading: "Loading"
            case .ready: "Ready"
            case let .failed(error): "Failed: \(error)"
            }
        }

        var isReady: Bool {
            if case .ready = self {
                return true
            } else {
                return false
            }
        }
    }

    @Published var playerState: PlayerState = .invalid
    @Published var player: AVQueuePlayer?

    private let eventsHandler: AdaptyEventsHandler
    private let onStateUpdated: (PlayerState) -> Void

    private var playerLooper: AVPlayerLooper?
    private var playerStatusObservation: NSKeyValueObservation?

    init(
        video: AdaptyUICore.VideoData,
        loop: Bool,
        eventsHandler: AdaptyEventsHandler,
        onStateUpdated: @escaping (PlayerState) -> Void
    ) {
        let playerItemToObserve: AVPlayerItem?

        switch video {
        case let .url(url, _):
            let playerItem = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(items: [playerItem])
            queuePlayer.isMuted = true

            if loop {
                playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            }

            player = queuePlayer

            playerItemToObserve = playerItem

            queuePlayer.play()
        case .resources:
            playerItemToObserve = nil
        }

        self.eventsHandler = eventsHandler
        self.onStateUpdated = onStateUpdated

        super.init()

        playerStatusObservation = playerItemToObserve?.observe(
            \.status,
            options: [.old, .new, .initial, .prior],
            changeHandler: { [weak self] item, _ in
                DispatchQueue.main.async { [weak self] in
                    self?.playerStatusDidChange(item.status, item: item)
                }
            }
        )
    }

    private func playerStatusDidChange(_ status: AVPlayerItem.Status, item: AVPlayerItem) {
        switch status {
        case .unknown:
            Log.ui.verbose("#AdaptyUIVideoPlayerManager# playerStatusDidChange = unknown")
            playerState = .loading
        case .readyToPlay:
            Log.ui.verbose("#AdaptyUIVideoPlayerManager# playerStatusDidChange = readyToPlay")
            playerState = .ready
        case .failed:
            if let error = item.error {
                Log.ui.verbose("#AdaptyUIVideoPlayerManager# playerStatusDidChange = error: \(error.localizedDescription)")
                playerState = .failed(error.localizedDescription)
            } else {
                Log.ui.verbose("#AdaptyUIVideoPlayerManager# playerStatusDidChange = unknown error")
                playerState = .failed("unknown error")
            }
        @unknown default:
            break
        }

        onStateUpdated(playerState)
    }

    deinit {
        playerStatusObservation?.invalidate()
        playerStatusObservation = nil
    }
}

#endif
