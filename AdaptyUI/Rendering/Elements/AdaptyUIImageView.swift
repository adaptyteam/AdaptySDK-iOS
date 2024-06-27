//
//  AdaptyUIImageView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI
import UIKit

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func aspectRatio(_ aspect: AdaptyUI.AspectRatio) -> some View {
        switch aspect {
        case .fit:
            aspectRatio(contentMode: .fit)
        case .fill:
            // TODO: fix this behaviour
            GeometryReader { proxy in
//            GeometryReaderWithFitHeight { width in
                self
                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: width)
                    .frame(maxWidth: proxy.size.width)
            }
        case .stretch:
            self
        }
    }
}

@available(iOS 15.0, *)
struct AdaptyUIImageView: View {
    var asset: AdaptyUI.ImageData
    var aspect: AdaptyUI.AspectRatio
    var tint: AdaptyUI.ColorFilling?

    init(asset: AdaptyUI.ImageData, aspect: AdaptyUI.AspectRatio, tint: AdaptyUI.ColorFilling? = nil) {
        self.asset = asset
        self.aspect = aspect
        self.tint = tint
    }

    init(_ image: AdaptyUI.Image) {
        self.asset = image.asset
        self.aspect = image.aspect
        self.tint = image.tint
    }

    @ViewBuilder
    private func rasterImage(_ uiImage: UIImage?, tint: AdaptyUI.ColorFilling?) -> some View {
        if let uiImage {
            if let tint = tint?.asColor?.swiftuiColor {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tint)
                    .aspectRatio(aspect)

            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(aspect)
            }
        } else {
            EmptyView()
        }
    }

    var body: some View {
        switch asset {
        case let .resorces(name):
            rasterImage(UIImage(named: name), tint: tint)
        case let .raster(data):
            rasterImage(UIImage(data: data), tint: tint)
        case let .url(url, preview):
            KFImage
                .url(url)
                .resizable()
                .placeholder {
                    if let preview {
                        rasterImage(UIImage(data: preview), tint: tint)
                    } else {
                        EmptyView()
                    }
                }
                .aspectRatio(aspect)
        }
    }
}

#endif
