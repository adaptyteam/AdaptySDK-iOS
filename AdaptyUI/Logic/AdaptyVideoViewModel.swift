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

public enum AdaptyCustomVideoAsset {
    case file(url: URL, preview: AdaptyCustomImageAsset?)
    case remote(url: URL, preview: AdaptyCustomImageAsset?)
    case player(item: AVPlayerItem, player: AVQueuePlayer, preview: AdaptyCustomImageAsset?)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyVideoAssetResolver: Sendable {
    func video(for id: String) -> AdaptyCustomVideoAsset?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package class AdaptyVideoViewModel: ObservableObject {
    let eventsHandler: AdaptyEventsHandler
    let assetResolver: AdaptyVideoAssetResolver?

    package init(
        eventsHandler: AdaptyEventsHandler,
        assetResolver: AdaptyVideoAssetResolver?
    ) {
        self.eventsHandler = eventsHandler
        self.assetResolver = assetResolver
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
            assetResolver: assetResolver
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
            case .failed(let error): "Failed: \(error)"
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

    static func initializePlayerFromAsset(
        video: VC.VideoData,
        assetResolver: AdaptyVideoAssetResolver?
    ) -> (AVPlayerItem, AVQueuePlayer)? {
        if let videoId = video.customId, let customAsset = assetResolver?.video(for: videoId) {
            switch customAsset {
            case .file(let url, _), .remote(let url, _):
                let playerItem = AVPlayerItem(url: url)
                let queuePlayer = AVQueuePlayer(items: [playerItem])
                queuePlayer.isMuted = true

                return (playerItem, queuePlayer)
            case .player(let playerItem, let queuePlayer, _):
                return (playerItem, queuePlayer)
            }
        }

        let playerItem = AVPlayerItem(url: video.url)
        let queuePlayer = AVQueuePlayer(items: [playerItem])
        queuePlayer.isMuted = true

        return (playerItem, queuePlayer)
    }

    init(
        video: VC.VideoData,
        loop: Bool,
        eventsHandler: AdaptyEventsHandler,
        assetResolver: AdaptyVideoAssetResolver?,
        onStateUpdated: @escaping (PlayerState) -> Void
    ) {
        let playerItemToObserve: AVPlayerItem?

        if let (playerItem, queuePlayer) = Self.initializePlayerFromAsset(video: video, assetResolver: assetResolver) {
            playerItemToObserve = playerItem
            player = queuePlayer

            if loop {
                playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            } else {
                playerLooper = nil
            }
        } else {
            playerItemToObserve = nil
            player = nil
            playerLooper = nil
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
        player?.play()
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
