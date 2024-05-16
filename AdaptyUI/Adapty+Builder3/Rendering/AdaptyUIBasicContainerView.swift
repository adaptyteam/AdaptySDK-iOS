//
//  AdaptyUIBasicContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//
#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 13.0, *)
struct AdaptyUIBasicContainerView<CloseButton: View>: View {
    var screen: AdaptyUI.Screen
    var mainImageHeight: Double = 320 // TODO: remove

    var closeButtonBuilder: (() -> CloseButton)?

    @ViewBuilder
    func imageView(_ image: AdaptyUI.Image) -> some View {
        GeometryReader { p in
            let minY = p.frame(in: .global).minY
            let isScrolling = minY > 0

            AdaptyUIImageView(image)
                .frame(width: p.size.width,
                       height: isScrolling ? mainImageHeight + minY : mainImageHeight)
                .clipped()
                .offset(y: isScrolling ? -minY : 0)
        }
        .frame(height: mainImageHeight)
    }

    @State var footerSize: CGSize = .zero

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    if case let .image(cover,_) = screen.cover {
                        imageView(cover)
                    }

                        AdaptyUIElementView(screen.content)
                    
                }
                .padding(.bottom, footerSize.height)
            }

            if let footer = screen.footer {
                // TODO: find a better solution
                GeometryReader { p in
                    Path { _ in
                        DispatchQueue.main.async {
                            footerSize = p.size
                        }
                    }

                    AdaptyUIElementView(footer)
                }
                .fixedSize(horizontal: false, vertical: true)
            }

            if let closeButtonBuilder {
                closeButtonBuilder()
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .topLeading)
            }
        }
    }
}

#if DEBUG

@testable import Adapty

@available(iOS 13.0, *)
#Preview {
    AdaptyUIBasicContainerView(
        screen: .init(
            background: .color(.testWhite),
            cover: .image(.testFill, nil),
            content: .stack(.testVStack, nil),
            footer: .stack(.testHStack, nil),
            overlay: nil
        ),
        closeButtonBuilder: {
            Button(action: {}, label: { Text("Dismiss") })
        }
    )
}
#endif

#endif
