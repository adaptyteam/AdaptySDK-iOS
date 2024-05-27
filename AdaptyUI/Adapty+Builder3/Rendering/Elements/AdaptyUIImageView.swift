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

@available(iOS 13.0, *)
extension View {
    @ViewBuilder
    func aspectRatio(_ aspect: AdaptyUI.AspectRatio) -> some View {
        switch aspect {
        case .fit:
            aspectRatio(contentMode: .fit)
        case .fill:
            aspectRatio(contentMode: .fill)
        case .stretch:
            self
        }
    }
}

@available(iOS 13.0, *)
struct AdaptyUIImageView: View {
    var asset: AdaptyUI.ImageData
    var aspect: AdaptyUI.AspectRatio
    var tint: AdaptyUI.Filling?

    init(asset: AdaptyUI.ImageData, aspect: AdaptyUI.AspectRatio, tint: AdaptyUI.Filling? = nil) {
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
    private func rasterImage(_ uiImage: UIImage?, tint: AdaptyUI.Filling?) -> some View {
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
                    .aspectRatio(contentMode: .fill)
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
            if #available(iOS 14.0, *) {
                // TODO: Add support for tint
                KFImage
                    .url(url)
                    .resizable()
                    .fade(duration: 0.25)
                    .placeholder {
                        if let preview {
                            rasterImage(UIImage(data: preview), tint: tint)
                        } else {
                            EmptyView()
                        }
                    }
                    .aspectRatio(aspect)
            } else {
                // TODO: implement AsyncImage logic
                if let preview, let uiImage = UIImage(data: preview) {
                    Image(uiImage: uiImage)
                        .aspectRatio(aspect)
                } else {
                    EmptyView()
                }
            }
        case .none:
            EmptyView()
        }
    }
}

#if DEBUG
@testable import Adapty

@available(iOS 13.0, *)
#Preview {
    AdaptyUIImageView(.test)
}
#endif

#endif
