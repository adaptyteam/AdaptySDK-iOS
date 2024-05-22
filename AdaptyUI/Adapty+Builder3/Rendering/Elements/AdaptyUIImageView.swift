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
    var image: AdaptyUI.Image

    init(_ image: AdaptyUI.Image) {
        self.image = image
    }

    @ViewBuilder
    private func rasterImage(_ uiImage: UIImage?, tint: AdaptyUI.Filling?) -> some View {
        if let uiImage  {
            if let tint = image.tint?.asColor?.swiftuiColor {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tint)
                    .aspectRatio(image.aspect)

            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .aspectRatio(image.aspect)
            }
        } else {
            EmptyView()
        }
    }

    var body: some View {
        switch image.asset {
        case let .resorces(name):
            rasterImage(UIImage(named: name), tint: image.tint)
        case let .raster(data):
            rasterImage(UIImage(data: data), tint: image.tint)
        case let .url(url, preview):
            if #available(iOS 14.0, *) {
                // TODO: Add support for tint
                KFImage
                    .url(url)
                    .resizable()
                    .fade(duration: 0.25)
                    .placeholder {
                        if let preview {
                            rasterImage(UIImage(data: preview), tint: image.tint)
                        } else {
                            EmptyView()
                        }
                    }
                    .aspectRatio(image.aspect)
            } else {
                // TODO: implement AsyncImage logic
                if let preview, let uiImage = UIImage(data: preview) {
                    Image(uiImage: uiImage)
                        .aspectRatio(image.aspect)
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
