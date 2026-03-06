//
//  SwiftUIView.swift
//
//
//  Created by Aleksey Goncharov on 25.07.2024.
//

#if canImport(UIKit)

import AVKit
import Combine
import SwiftUI

extension VC.AspectRatio {
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .stretch: .resize
        }
    }
}

struct AdaptyUIVideoPlayerView: UIViewControllerRepresentable {
    var player: AVPlayer
    var videoGravity: AVLayerVideoGravity
    var onReadyForDisplay: () -> Void

    @State private var playerStatusObservation: NSKeyValueObservation?

    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.view.backgroundColor = .clear

        playerViewController.showsPlaybackControls = false
        playerViewController.updatesNowPlayingInfoCenter = false
        playerViewController.requiresLinearPlayback = true
        playerViewController.player = player
        playerViewController.videoGravity = videoGravity
        playerViewController.allowsPictureInPicturePlayback = false
        player.seek(to: .zero)
        player.play()

        DispatchQueue.main.async {
#if os(visionOS)
            playerStatusObservation = playerViewController.player?.observe(
                \.status,
                options: [.old, .new],
                changeHandler: { player, _ in
                    DispatchQueue.main.async {
                        if player.status == .readyToPlay {
                            onReadyForDisplay()
                        }
                    }
                }
            )
#else
            playerStatusObservation = playerViewController.observe(
                \.isReadyForDisplay,
                options: [.new, .initial],
                changeHandler: { playerVC, _ in
                    DispatchQueue.main.async {
                        if playerVC.isReadyForDisplay {
                            DispatchQueue.main.async {
                                onReadyForDisplay()
                            }
                        }
                    }
                }
            )
#endif
        }

        return playerViewController
    }

    func updateUIViewController(_: AVPlayerViewController, context _: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator _: ()) {
        uiViewController.player?.pause()
        uiViewController.player = nil
    }
}

struct AdaptyUIVideoView: View {
    @EnvironmentObject
    private var viewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @State
    private var showPlaceholder = true

    private let video: VC.VideoPlayer

    init(video: VC.VideoPlayer) {
        self.video = video
    }

    var body: some View {
        if let videoAsset = viewModel.resolvedAsset(
            video.asset,
            mode: colorScheme.toVCMode,
            screen: screen
        ).asVideoAsset {
            let playerManager = viewModel.getOrCreatePlayerManager(
                for: videoAsset,
                assetRef: video.asset,
                loop: video.loop
            )

            ZStack {
                if let player = playerManager.player {
                    AdaptyUIVideoPlayerView(
                        player: player,
                        videoGravity: video.aspect.videoGravity,
                        onReadyForDisplay: {
                            showPlaceholder = false
                        }
                    )
                }

                if showPlaceholder, let placeholder = videoAsset.image {
                    AdaptyUIImageView(
                        .resolvedImageAsset(
                            asset: placeholder,
                            aspect: video.aspect,
                            tint: nil
                        )
                    )
                }
            }
        } else {
            Rectangle()
        }
    }
}

#endif
