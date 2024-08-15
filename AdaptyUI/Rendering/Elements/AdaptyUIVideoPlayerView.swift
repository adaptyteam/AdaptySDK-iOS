//
//  SwiftUIView.swift
//
//
//  Created by Aleksey Goncharov on 25.07.2024.
//

#if canImport(UIKit)

import Adapty
import AVKit
import Combine
import SwiftUI

extension AdaptyUI.AspectRatio {
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .stretch: .resize
        }
    }
}

@available(iOS 15.0, *)
struct AdaptyUIVideoPlayerView: UIViewControllerRepresentable {
    var player: AVPlayer
    var videoGravity: AVLayerVideoGravity
    var onReadyForDisplay: () -> Void

    @State private var playerStatusObservation: NSKeyValueObservation?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.view.backgroundColor = .clear

        playerViewController.showsPlaybackControls = false
        playerViewController.updatesNowPlayingInfoCenter = false
        playerViewController.requiresLinearPlayback = true
        playerViewController.player = player
        playerViewController.videoGravity = videoGravity

        DispatchQueue.main.async {
            playerStatusObservation = playerViewController.observe(
                \.isReadyForDisplay,
                 options: [.old, .new, .initial, .prior],
                 changeHandler: { playerVC, change in
                     if playerVC.isReadyForDisplay {
                         DispatchQueue.main.async {
                             onReadyForDisplay()
                         }
                     }
                 }
            )
        }

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
        uiViewController.player = nil
    }
}

@available(iOS 15.0, *)
struct AdaptyUIVideoView: View {
    @EnvironmentObject var viewModel: AdaptyVideoViewModel
    @State var showPlaceholder = true

    let id: String = UUID().uuidString
    let video: AdaptyUI.VideoPlayer
    let placeholderImageAsset: AdaptyUI.ImageData

    init(video: AdaptyUI.VideoPlayer) {
        self.video = video

        switch video.asset {
        case let .url(_, image), let .resources(_, image):
            placeholderImageAsset = image
        }
    }

    var body: some View {
        ZStack {
            if let player = viewModel.playerManagers[id]?.player {
                AdaptyUIVideoPlayerView(
                    player: player,
                    videoGravity: video.aspect.videoGravity,
                    onReadyForDisplay: {
                        showPlaceholder = false
                    }
                )
            }

            if showPlaceholder {
                AdaptyUIImageView(
                    asset: placeholderImageAsset,
                    aspect: video.aspect,
                    tint: nil
                )
            }
        }
        .onAppear {
            viewModel.initializePlayerManager(for: video, id: id)
        }
        .onDisappear {
            viewModel.dismissPlayerManager(id: id)
        }
    }
}

#if DEBUG

extension AdaptyUI.VideoPlayer {
    private static let url1 = URL(string: "https://firebasestorage.googleapis.com/v0/b/api-8970033217728091060-294809.appspot.com/o/Paywall%20video%201.mp4?alt=media&token=5e7ac250-091e-4bb3-8a99-6ac4f0735b37")!

    private static let url2 = URL(string: "https://firebasestorage.googleapis.com/v0/b/api-8970033217728091060-294809.appspot.com/o/Paywall%20video%202.mp4?alt=media&token=8735a549-d035-432f-b609-fe795bfb4efb")!

    private static let url3 = URL(string: "https://firebasestorage.googleapis.com/v0/b/api-8970033217728091060-294809.appspot.com/o/Paywall%20video%203.mov?alt=media&token=ba0e2ec6-f81e-424f-84e6-e18617bedfbf")!

    static let test1 = AdaptyUI.VideoPlayer.create(
        asset: .url(url1, image: .resources("video_preview_0")),
        aspect: .stretch,
        loop: true
    )

    static let test2 = AdaptyUI.VideoPlayer.create(
        asset: .url(url2, image: .resources("general-tab-icon")),
        aspect: .fit,
        loop: false
    )
    static let test3 = AdaptyUI.VideoPlayer.create(
        asset: .url(url3, image: .resources("general-tab-icon")),
        aspect: .fill,
        loop: true
    )
}

@available(iOS 15.0, *)
#Preview {
    VStack {
        AdaptyUIVideoView(video: .test1)
        AdaptyUIVideoView(video: .test2)
        AdaptyUIVideoView(video: .test3)
    }
}

@available(iOS 15.0, *)
public struct AdaptyUIVideoTestView: View {
    public init() {}

    public var body: some View {
        VStack {
            AdaptyUIVideoView(video: .test1)
            AdaptyUIVideoView(video: .test2)
            AdaptyUIVideoView(video: .test3)
        }
    }
}

#endif

#endif
