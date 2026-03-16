//
//  AdaptyUIElementView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

extension View {
    @ViewBuilder
    func paddingIfNeeded(_ insets: EdgeInsets?) -> some View {
        if let insets {
            padding(insets)
        } else {
            self
        }
    }
}

@MainActor
struct AdaptyUIElementWithoutPropertiesView<ScreenHolderContent: View>: View {
    private let element: VC.Element
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ element: VC.Element,
        screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.element = element
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        switch element {
        case let .space(count):
            if count > 0 {
                ForEach(0 ..< count, id: \.self) { _ in
                    Spacer()
                }
            }
        case let .box(box, props):
            elementOrEmpty(box.content)
                .animatableFrame(
                    box: box,
                    animations: props?.onAppear
                )
                .rangedFrame(box: box)
        case let .stack(stack, _):
            AdaptyUIStackView(
                stack,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .text(text, _):
            AdaptyUITextView(text)
        case let .textField(textField, _):
            AdaptyUITextField(textField)
        case let .slider(slider, _):
            AdaptyUISliderView(slider)
        case let .image(image, _):
            AdaptyUIImageView(.unresolvedAsset(image))
        case let .video(video, _):
            AdaptyUIVideoView(video: video)
        case let .button(button, _):
            AdaptyUIButtonView(button)
        case let .row(row, _):
            AdaptyUIRowView(
                row,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .column(column, _):
            AdaptyUIColumnView(
                column,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .section(section, _):
            AdaptyUISectionView(
                section,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .toggle(toggle, _):
            AdaptyUIToggleView(toggle)
        case let .timer(timer, _):
            AdaptyUITimerView(timer)
        case let .pager(pager, _):
            AdaptyUIPagerView(
                pager,
                screenHolderBuilder: screenHolderBuilder
            )
        case .screenHolder:
            screenHolderBuilder()
        case .dateTimePicker:
            AdaptyUIUnknownElementView(value: "date-time picker")
        case .wheelItemsPicker:
            AdaptyUIUnknownElementView(value: "wheel items picker")
        case .wheelRangePicker:
            AdaptyUIUnknownElementView(value: "wheel range picker")
        case let .unknown(value, _):
            AdaptyUIUnknownElementView(value: value)
        }
    }

    @ViewBuilder
    private func elementOrEmpty(_ content: VC.Element?) -> some View {
        if let content {
            AdaptyUIElementView(
                content,
                screenHolderBuilder: screenHolderBuilder
            )
        } else {
            Color.clear
                .frame(idealWidth: 0, idealHeight: 0)
        }
    }
}

struct AdaptyUIElementView<ScreenHolderContent: View>: View {
    private let element: VC.Element
    private let additionalPadding: EdgeInsets?
    private let drawDecoratorBackground: Bool
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ element: VC.Element,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent,
        additionalPadding: EdgeInsets? = nil,
        drawDecoratorBackground: Bool = true
    ) {
        self.element = element
        self.screenHolderBuilder = screenHolderBuilder
        self.additionalPadding = additionalPadding
        self.drawDecoratorBackground = drawDecoratorBackground
    }

    @State
    private var playOnAppearAnimations: [VC.Animation] = []

    var body: some View {
        AdaptyUIElementWithoutPropertiesView(
            element,
            screenHolderBuilder: screenHolderBuilder
        )
        .paddingIfNeeded(additionalPadding)
        .animatableDecorator(
            element.properties?.decorator,
            animations: element.properties?.onAppear,
            includeBackground: drawDecoratorBackground
        )
        .animatableProperties(element.properties, play: $playOnAppearAnimations)
        .padding(element.properties?.padding)
        .modifier(DebugOverlayModifier())
        .onAppear {
            playOnAppearAnimations = element.properties?.onAppear ?? []
        }
    }
}

#endif

