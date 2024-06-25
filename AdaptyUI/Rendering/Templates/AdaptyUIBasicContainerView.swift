//
//  AdaptyUIBasicContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//
#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
extension CoordinateSpace {
    static let adaptyBasicName = "adapty.container.basic"
    static let adaptyBasic = CoordinateSpace.named(adaptyBasicName)
}

@available(iOS 15.0, *)
struct AdaptyUIBasicContainerView: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @State
    private var footerSize: CGSize = .zero

    var screen: AdaptyUI.Screen

    @ViewBuilder
    func coverView(
        _ box: AdaptyUI.Box,
        _ content: AdaptyUI.Element,
        _ properties: AdaptyUI.Element.Properties?
    ) -> some View {
        let height: CGFloat = {
            if let boxHeight = box.height, case let .fixed(unit) = boxHeight {
                return unit.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
            } else {
                return 0.0
            }
        }()

        GeometryReader { p in
            let minY = p.frame(in: .adaptyBasic).minY
            let isScrollingDown = minY > 0
            let isScrollingUp = minY < 0

            AdaptyUIElementView(content)
                .frame(
                    width : p.size.width,
                    height: {
                        if isScrollingDown {
                            return height + minY
                        } else {
                            return height // - minY
                        }
                    }()
                )
                .clipped()
                .offset(
                    y: {
                        if isScrollingUp {
                            return -minY / 2.0
                        } else if isScrollingDown {
                            return -minY
                        } else {
                            return 0.0
                        }
                    }()
                )
        }
        .frame(height: height)
    }

    @ViewBuilder
    private func elementOrEmpty(_ content: AdaptyUI.Element?) -> some View {
        if let content {
            AdaptyUIElementView(content)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    func contentView(
        content: AdaptyUI.Element,
        coverBox: AdaptyUI.Box
    ) -> some View {
        let coverHeight: CGFloat = {
            if let boxHeight = coverBox.height, case let .fixed(unit) = boxHeight {
                return unit.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
            } else {
                return 0.0
            }
        }()

        let bottomOverscrollHeight = screenSize.height
        let properties = content.properties
        let selfHeight = screenSize.height - coverHeight
        let offsetY = properties?.offset.y ?? 0

        Group {
            switch content {
            case let .space(count):
                if count > 0 {
                    ForEach(0 ..< count, id: \.self) { _ in
                        Spacer()
                    }
                }
            case let .box(box, properties):
                elementOrEmpty(box.content)
                    .fixedFrame(box: box)
                    .rangedFrame(box: box)
            case let .stack(stack, properties):
                AdaptyUIStackView(stack)
            case let .text(text, properties):
                AdaptyUITextView(text)
            case let .image(image, properties):
                AdaptyUIImageView(image)
            case let .button(button, properties):
                AdaptyUIButtonView(button)
            case let .row(row, properties):
                AdaptyUIRowView(row)
            case let .column(column, properties):
                AdaptyUIColumnView(column)
            case let .section(section, properties):
                AdaptyUISectionView(section)
            case let .toggle(toggle, properties):
                AdaptyUIToggleView(toggle)
            case let .timer(timer, properties):
                AdaptyUITimerView(timer)
            case let .pager(pager, properties):
                AdaptyUIPagerView(pager)
            case let .unknown(value, properties):
                AdaptyUIUnknownElementView(value: value)
            }
        }
        .padding(.bottom, footerSize.height - offsetY + bottomOverscrollHeight)
        .applyingProperties(properties)
        .padding(.bottom, offsetY - bottomOverscrollHeight)
    }

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .bottom) {
                if let coverBox = screen.cover, let coverContent = coverBox.content {
                    ScrollView {
                        VStack(spacing: 0) {
                            coverView(
                                coverBox,
                                coverContent,
                                nil
                            )

                            contentView(
                                content: screen.content,
                                coverBox: coverBox
                            )
                        }
                    }
                    .ignoresSafeArea()
                    .scrollIndicatorsHidden_compatible()
                }

                if let footer = screen.footer {
                    AdaptyUIElementView(footer)
                        .onGeometrySizeChange { footerSize = $0 }
                }

                if let overlay = screen.overlay {
                    AdaptyUIElementView(overlay)
                }
            }
            .coordinateSpace(name: CoordinateSpace.adaptyBasicName)
            .ignoresSafeArea()
        }
    }
}

#endif
