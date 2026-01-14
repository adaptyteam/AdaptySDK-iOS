//
//  AdaptyUIVideoViewModel.swift
//
//
//  Created by Aleksey Goncharov on 15.08.2024.
//

#if canImport(UIKit)

import AVKit
import SwiftUI

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

    private let onStateUpdated: (PlayerState) -> Void

    private var playerLooper: AVPlayerLooper?
    private var playerStatusObservation: NSKeyValueObservation?

    init(
        video: AdaptyUIResolvedVideoAsset,
        loop: Bool,
        onStateUpdated: @escaping (PlayerState) -> Void
    ) {
        player = video.player

        if loop {
            playerLooper = AVPlayerLooper(
                player: video.player,
                templateItem: video.item
            )
        } else {
            playerLooper = nil
        }

        self.onStateUpdated = onStateUpdated

        super.init()

        playerStatusObservation = video.item.observe(
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

    private func playerStatusDidChange(
        _ status: AVPlayerItem.Status,
        item: AVPlayerItem
    ) {
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
