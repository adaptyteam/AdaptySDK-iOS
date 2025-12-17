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
                options: [.old, .new, .initial, .prior],
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

    private let video: VC.VideoPlayer

    init(video: VC.VideoPlayer, colorScheme _: ColorScheme) {
        self.video = video
    }

    private let id: String = UUID().uuidString

    @ViewBuilder
    private func colorSchemeVideoView(videoData: VC.VideoData, id: String) -> some View {
        AdaptyUIVideoColorSchemeSpecificView(
            video: videoData,
            aspect: video.aspect,
            loop: video.loop
        )
        .environmentObject(viewModel)
        .environmentObject(
            viewModel.getOrCreatePlayerManager(
                for: videoData,
                loop: video.loop,
                id: id
            )
        )
        .onDisappear {
            viewModel.dismissPlayerManager(id: id)
        }
    }

    var body: some View {
        switch colorScheme {
        case .light:
            colorSchemeVideoView(
                videoData: video.asset.mode(.light),
                id: id
            )
        case .dark:
            colorSchemeVideoView(
                videoData: video.asset.mode(.dark),
                id: id
            )
        @unknown default:
            colorSchemeVideoView(
                videoData: video.asset.mode(.light),
                id: id
            )
        }
    }
}

struct AdaptyUIVideoColorSchemeSpecificView: View {
    @EnvironmentObject
    private var viewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var playerManager: AdaptyUIVideoPlayerManager

    @State
    private var showPlaceholder = true

    private let video: VC.VideoData
    private let aspect: VC.AspectRatio
    private let loop: Bool
    private let placeholder: VC.ImageData

    init(
        video: VC.VideoData,
        aspect: VC.AspectRatio,
        loop: Bool
    ) {
        self.video = video
        self.aspect = aspect
        self.loop = loop
        self.placeholder = video.image
    }

    var body: some View {
        ZStack {
            if let player = playerManager.player {
                AdaptyUIVideoPlayerView(
                    player: player,
                    videoGravity: aspect.videoGravity,
                    onReadyForDisplay: {
                        showPlaceholder = false
                    }
                )
            }

            if showPlaceholder {
                AdaptyUIImageView(
                    asset: placeholder,
                    aspect: aspect,
                    tint: nil
                )
            }
        }
    }
}

#if DEBUG

//extension VC.VideoPlayer {
//    private static let url1 = URL(string: "https://firebasestorage.googleapis.com/v0/b/api-8970033217728091060-294809.appspot.com/o/Paywall%20video%201.mp4?alt=media&token=5e7ac250-091e-4bb3-8a99-6ac4f0735b37")!
//
//    private static let imgUrl = URL(string: "http://www.libpng.org/pub/png/img_png/OwlAlpha.png")!
//
//    private static let url2 = URL(string: "https://firebasestorage.googleapis.com/v0/b/api-8970033217728091060-294809.appspot.com/o/Paywall%20video%202.mp4?alt=media&token=8735a549-d035-432f-b609-fe795bfb4efb")!
//
//    private static let url3 = URL(string: "https://firebasestorage.googleapis.com/v0/b/api-8970033217728091060-294809.appspot.com/o/Paywall%20video%203.mov?alt=media&token=ba0e2ec6-f81e-424f-84e6-e18617bedfbf")!
//
//    static let test1 = VC.VideoPlayer.create(
//        asset: .same(.create(url: url1, image: .create(customId: "video_preview_0", url: imgUrl))),
//        aspect: .stretch,
//        loop: true
//    )
//
//    static let test2 = VC.VideoPlayer.create(
//        asset: .same(.create(url: url2, image: .create(customId: "general-tab-icon", url: imgUrl))),
//        aspect: .fit,
//        loop: false
//    )
//    static let test3 = VC.VideoPlayer.create(
//        asset: .same(.create(url: url3, image: .create(customId: "general-tab-icon", url: imgUrl))),
//        aspect: .fill,
//        loop: true
//    )
//}

//#Preview {
//    VStack {
//        AdaptyUIVideoView(video: .test1, colorScheme: .light)
//        AdaptyUIVideoView(video: .test2, colorScheme: .light)
//        AdaptyUIVideoView(video: .test3, colorScheme: .light)
//    }
//}

//public struct AdaptyUIVideoTestView: View {
//    public init() {}
//
//    public var body: some View {
//        VStack {
//            AdaptyUIVideoView(video: .test1, colorScheme: .light)
//            AdaptyUIVideoView(video: .test2, colorScheme: .light)
//            AdaptyUIVideoView(video: .test3, colorScheme: .light)
//        }
//    }
//}

#endif

#endif
