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
    private var playAnimations: Binding<[VC.Animation]>

    init(
        _ element: VC.Element,
        playAnimations: Binding<[VC.Animation]>,
        screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.element = element
        self.playAnimations = playAnimations
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        switch element {
        case let .box(box, props):
            elementOrEmpty(box.content)
                .animatableFrame(
                    box: box,
                    play: playAnimations
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
        case let .legacyRow(row, _):
            AdaptyUIRowView(
                row,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .legacyColumn(column, _):
            AdaptyUIColumnView(
                column,
                screenHolderBuilder: screenHolderBuilder
            )
        case let .row(row, _):
            AdaptyUIRowView(
                .init(spacing: row.spacing, items: row.items), // TODO: use new row
                screenHolderBuilder: screenHolderBuilder
            )
        case let .column(column, _):
            AdaptyUIColumnView(
                .init(spacing: column.spacing, items: column.items), // TODO: use new column
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
        case let .textProgress(textProgress, _):
            AdaptyUITextProgressView(textProgress)
        case let .linearProgress(linearProgress, _):
            AdaptyUILinearProgressView(linearProgress)
        case let .radialProgress(radialProgress, _):
            AdaptyUIRadialProgressView(radialProgress)
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

    @EnvironmentObject private var eventBus: AdaptyUIEventBus
    @EnvironmentObject private var navigatorViewModel: AdaptyUINavigatorViewModel
    @EnvironmentObject private var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.adaptyScreenInstanceId) private var screenInstanceId: String?

    @State private var playAnimations: [VC.Animation] = []
    @State private var lastProcessedSequence: UInt = 0

    var body: some View {
        AdaptyUIElementWithoutPropertiesView(
            element,
            playAnimations: $playAnimations,
            screenHolderBuilder: screenHolderBuilder
        )
        .animatableDecorator(
            element.properties?.decorator,
            play: $playAnimations,
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
        .animatableProperties(element.properties, play: $playAnimations)
        .padding(element.properties?.padding)
        .modifier(ElementInteractionEnabledModifier(element.properties?.interactionEnabled))
        .modifier(DebugOverlayModifier())
        .onAppear {
            consumeAndProcessPendingEvents()
        }
        .onChange(of: eventBus.revision) { _ in
            consumeAndProcessPendingEvents()
        }
    }

    private func consumeAndProcessPendingEvents() {
        guard let properties = element.properties,
              properties.eventHandlers.isNotEmpty else { return }

        let pending = eventBus.consumePending(
            afterSequence: lastProcessedSequence,
            screenInstanceId: screenInstanceId,
            currentTopScreenInstanceId: navigatorViewModel.currentScreenInstanceIfSingle?.id
        )

        guard !pending.isEmpty else { return }

        for event in pending {
            processEvent(event, properties: properties)
        }

        lastProcessedSequence = pending.last!.sequence
    }

    private func processEvent(_ event: AdaptyUIEventBus.Event, properties: VC.Element.Properties) {
        for eventHandler in properties.eventHandlers {
            guard shouldFireHandler(eventHandler, for: event) else { continue }
            if eventHandler.animations.isNotEmpty {
                if playAnimations == eventHandler.animations {
                    // Same animations — reset first, defer re-set to next run loop
                    playAnimations = []
                    DispatchQueue.main.async {
                        playAnimations = eventHandler.animations
                    }
                } else {
                    playAnimations = eventHandler.animations
                }
            }

            if eventHandler.onAnimationsFinish.isNotEmpty {
                scheduleAnimationsFinish(eventHandler)
            }
        }
    }

    private func shouldFireHandler(
        _ handler: VC.EventHandler,
        for event: AdaptyUIEventBus.Event
    ) -> Bool {
        for trigger in handler.triggers {
            guard trigger.events.contains(event.eventId) else { continue }

            if let allowedTransitions = trigger.screenTransitions {
                guard let tid = event.transitionId,
                      allowedTransitions.contains(tid) else { continue }
            }

            let count = eventBus.fireCount(screenInstanceId: event.screenInstanceId, eventId: event.eventId)
            if let filter = trigger.filter {
                switch filter {
                case .first: guard count <= 1 else { continue }
                case .notFirst: guard count > 1 else { continue }
                }
            }

            return true
        }
        return false
    }

    private func scheduleAnimationsFinish(_ handler: VC.EventHandler) {
        // Infinite loops (loop != nil && loopCount == nil) never finish
        let hasInfiniteLoop = handler.animations.contains {
            $0.timeline.loop != nil && $0.timeline.loopCount == nil
        }
        guard !hasInfiniteLoop else { return }

        let totalDuration = handler.animations
            .map { animation -> TimeInterval in
                let tl = animation.timeline
                let baseDuration = tl.duration + tl.startDelay
                guard let loop = tl.loop, let loopCount = tl.loopCount else {
                    return baseDuration
                }
                let loopDuration: TimeInterval =
                    switch loop {
                    case .normal:
                        tl.duration + tl.loopDelay
                    case .pingPong:
                        tl.duration * 2 + tl.pingPongDelay
                    }
                return baseDuration + loopDuration * Double(loopCount)
            }
            .max() ?? 0

        let actions = handler.onAnimationsFinish
        guard let screenInstance = navigatorViewModel.currentScreenInstanceIfSingle else { return }

        if totalDuration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak stateViewModel] in
                stateViewModel?.execute(actions: actions, screen: screenInstance)
            }
        } else {
            stateViewModel.execute(actions: actions, screen: screenInstance)
        }
    }
}

#endif

