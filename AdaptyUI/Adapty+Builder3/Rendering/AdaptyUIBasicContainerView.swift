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
struct AdaptyUIBasicContainerView: View {
    var screen: AdaptyUI.Screen

//    @ViewBuilder
//    func imageView(_ image: AdaptyUI.Image, height: CGFloat) -> some View {
//        GeometryReader { p in
//            let minY = p.frame(in: .global).minY
//            let isScrolling = minY > 0
//
//            AdaptyUIImageView(image)
//                .frame(width: p.size.width,
//                       height: isScrolling ? height + minY : height)
//                .clipped()
//                .offset(y: isScrolling ? -minY : 0)
//        }
//        .frame(height: height)
//    }
//    
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    
    @ViewBuilder
    func coverView(_ box: AdaptyUI.Box,
                   _ properties: AdaptyUI.Element.Properties?) -> some View {
        let height: CGFloat = {
            if let boxHeight = box.height, case .fixed(let unit) = boxHeight {
                return unit.points(screenSize: screenSize.height)
            } else {
                return 0.0
            }
        }()
                
        GeometryReader { p in
            let minY = p.frame(in: .global).minY
            let isScrolling = minY > 0
            

            AdaptyUIElementView(box.content)
//                .fixedFrame(box: box)
//                .rangedFrame(box: box)
                .frame(width: p.size.width,
                       height: isScrolling ? height + minY : height)
                .applyingProperties(properties)
                .clipped()
                .offset(y: isScrolling ? -minY : 0)
        }
        .frame(height: height)
    }

    @State var footerSize: CGSize = .zero

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
//                    if case let .image(cover, _) = screen.cover {
//                        imageView(cover, height: 200.0)
//                    }
                    
                    if case let .box(box, properties) = screen.cover {
                        coverView(box, properties)
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
        }
    }
}

//#if DEBUG
//
//@testable import Adapty
//
//@available(iOS 13.0, *)
//#Preview {
//    AdaptyUIBasicContainerView(
//        screen: .init(
//            background: .color(.testWhite),
//            cover: .image(.testFill, nil),
//            content: .stack(.testVStack, nil),
//            footer: .stack(.testHStack, nil),
//            overlay: nil
//        )
//    )
//}
//#endif
//
#endif
