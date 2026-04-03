//
//  AdaptyUIElementView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI

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
        case let .textField(textField, props):
            AdaptyUITextField(textField, focusId: props?.focusId)
        case let .slider(slider, _):
            AdaptyUISliderView(slider)
        case let .image(image, _):
            AdaptyUIImageView(.unresolvedAsset(image))
        case let .video(video, _):
            AdaptyUIVideoView(video: video)
        case let .button(button, _):
            AdaptyUIButtonView(button)
        case let .row(row, _):
            AdaptyUIFlexRowView(
                row,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .column(column, _):
            AdaptyUIFlexColumnView(
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
        case let .dateTimePicker(dateTimePicker, _):
            AdaptyUIDateTimePickerView(dateTimePicker)
        case let .wheelItemsPicker(wheelItemsPicker, _):
            AdaptyUIWheelItemsPickerView(wheelItemsPicker)
        case let .wheelRangePicker(wheelRangePicker, _):
            AdaptyUIWheelRangePickerView(wheelRangePicker)
        case let .unknown(value):
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
    private let drawDecoratorBackground: Bool
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ element: VC.Element,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent,
        drawDecoratorBackground: Bool = true
    ) {
        self.element = element
        self.screenHolderBuilder = screenHolderBuilder
        self.drawDecoratorBackground = drawDecoratorBackground
    }

    @State
    private var playOnAppearAnimations: [VC.Animation] = []

    var body: some View {
        AdaptyUIElementWithoutPropertiesView(
            element,
            screenHolderBuilder: screenHolderBuilder
        )
        .animatableDecorator(
            element.properties?.decorator,
            animations: element.properties?.onAppear,
            includeBackground: drawDecoratorBackground
        )
        .modifier(ElementBackgroundModifier(
            backgrounds: element.properties?.background,
            screenHolderBuilder: screenHolderBuilder
        ))
        .modifier(ElementOverlayModifier(
            overlays: element.properties?.overlay,
            screenHolderBuilder: screenHolderBuilder
        ))
        .animatableProperties(element.properties, play: $playOnAppearAnimations)
        .padding(element.properties?.padding)
        .modifier(ElementInteractionEnabledModifier(element.properties?.interactionEnabled))
        .modifier(DebugOverlayModifier())
        .onAppear {
            playOnAppearAnimations = element.properties?.onAppear ?? []
        }
    }
}

#endif
