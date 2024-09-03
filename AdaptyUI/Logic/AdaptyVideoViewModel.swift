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

@available(iOS 15.0, *)
package class AdaptyVideoViewModel: ObservableObject {
    let eventsHandler: AdaptyEventsHandler

    package init(eventsHandler: AdaptyEventsHandler) {
        self.eventsHandler = eventsHandler
    }

    @Published var playerStates = [String: AdaptyUIVideoPlayerManager.PlayerState]()
    @Published var playerManagers = [String: AdaptyUIVideoPlayerManager]()

    func initializePlayerManager(
        for video: AdaptyUI.VideoData,
        loop: Bool,
        id: String
    ) {
        if playerManagers.keys.contains(id) {
            return
        }

        let manager = AdaptyUIVideoPlayerManager(
            video: video,
            loop: loop,
            eventsHandler: eventsHandler
        ) { [weak self] state in
            self?.playerStates[id] = state
        }

        playerManagers[id] = manager
        playerStates[id] = .loading
    }

    func dismissPlayerManager(id: String) {
        playerManagers.removeValue(forKey: id)
    }
}

@available(iOS 15.0, *)
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
        video: AdaptyUI.VideoData,
        loop: Bool,
        eventsHandler: AdaptyEventsHandler,
        onStateUpdated: @escaping (PlayerState) -> Void
    ) {
        let playerItemToObserve: AVPlayerItem?

        switch video {
        case let .url(url, image):
            let playerItem = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(items: [playerItem])

            if loop {
                playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            }

            player = queuePlayer

            playerItemToObserve = playerItem

            queuePlayer.play()
        case let .resources(string, image):
            playerItemToObserve = nil
        }

        self.eventsHandler = eventsHandler
        self.onStateUpdated = onStateUpdated

        super.init()

        playerStatusObservation = playerItemToObserve?.observe(
            \.status,
            options: [.old, .new, .initial, .prior],
            changeHandler: { [weak self] item, _ in
                self?.playerStatusDidChange(item.status, item: item)
            }
        )
    }

    private func playerStatusDidChange(_ status: AVPlayerItem.Status, item: AVPlayerItem) {
        switch status {
        case .unknown:
            eventsHandler.log(.verbose, "#AdaptyUIVideoPlayerManager# playerStatusDidChange = unknown")
            playerState = .loading
        case .readyToPlay:
            eventsHandler.log(.verbose, "#AdaptyUIVideoPlayerManager# playerStatusDidChange = readyToPlay")
            playerState = .ready
        case .failed:
            if let error = item.error {
                eventsHandler.log(.verbose, "#AdaptyUIVideoPlayerManager# playerStatusDidChange = error: \(error.localizedDescription)")
                playerState = .failed(error.localizedDescription)
            } else {
                eventsHandler.log(.verbose, "#AdaptyUIVideoPlayerManager# playerStatusDidChange = unknown error")
                playerState = .failed("unknown error")
            }
        }

        onStateUpdated(playerState)
    }

    deinit {
        playerStatusObservation?.invalidate()
        playerStatusObservation = nil
    }
}

#endif
