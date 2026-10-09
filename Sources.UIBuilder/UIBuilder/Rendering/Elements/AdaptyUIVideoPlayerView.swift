//
//  SwiftUIView.swift
//
//
//  Created by Aleksey Goncharov on 25.07.2024.
//

#if canImport(UIKit)

import AVKit
import SwiftUI

extension VC.AspectRatio {
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .stretch: .resize
        }
    }

    var swiftUIContentMode: SwiftUI.ContentMode {
        switch self {
        case .fit: .fit
        case .fill, .stretch: .fill
        }
    }
}

extension View {
    @ViewBuilder
    func applyAspectLayout(ratio: Double?, aspect: VC.AspectRatio) -> some View {
        if let ratio {
            aspectRatio(ratio, contentMode: aspect.swiftUIContentMode)
        } else {
            frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private extension View {
    /// Lays out resizable image content the way `AVPlayerLayer` lays out video
    /// with the matching gravity: centered in the bounds. Without a bounded
    /// proposal it falls back to the content's own size.
    @ViewBuilder
    func videoGravityLayout(_ aspect: VC.AspectRatio) -> some View {
        switch aspect {
        case .fit, .fill:
            aspectRatio(contentMode: aspect.swiftUIContentMode)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        case .stretch:
            frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
}

/// The video's preview image, laid out like the video it stands in for, so the
/// first frame replaces it in place.
private struct AdaptyUIVideoPlaceholderView: View {
    let asset: AdaptyUIResolvedImageAsset
    let aspect: VC.AspectRatio

    var body: some View {
        switch asset {
        case .image(let image):
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .videoGravityLayout(aspect)
            }
        case .remote(let url, let preview):
            RemoteImage(
                url: url,
                placeholder: {
                    if let preview {
                        Image(uiImage: preview)
                            .resizable()
                            .videoGravityLayout(aspect)
                    }
                }
            )
            .resizable()
            .videoGravityLayout(aspect)
        }
    }
}

struct AdaptyUIVideoPlayerView: UIViewControllerRepresentable {
    var player: AVPlayer
    var videoGravity: AVLayerVideoGravity

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
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var viewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

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
                loop: video.loop,
                onPlayToEnd: video.actions.isEmpty ? nil : { [weak stateViewModel] in
                    stateViewModel?.execute(actions: video.actions, screen: screen)
                }
            )

            // The placeholder stays under the player for the element's lifetime:
            // the player layer is transparent until its first frame is composited,
            // so the placeholder shows through without a gap, however late that is.
            ZStack {
                if let placeholder = videoAsset.image {
                    AdaptyUIVideoPlaceholderView(asset: placeholder, aspect: video.aspect)
                        .allowsHitTesting(false)
                }

                if let player = playerManager.player {
                    AdaptyUIVideoPlayerView(
                        player: player,
                        videoGravity: video.aspect.videoGravity
                    )
                }
            }
            .applyAspectLayout(ratio: videoAsset.ratio, aspect: video.aspect)
            .clipped()
            .id(videoAsset.id)
        } else {
            Rectangle()
        }
    }
}

#endif
