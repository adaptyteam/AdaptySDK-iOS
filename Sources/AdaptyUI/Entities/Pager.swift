//
//  Pager.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 30.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Pager: Hashable, Sendable {
        static let `default` = Pager(
            pageWidth: .default,
            pageHeight: .default,
            pagePadding: .zero,
            spacing: 0,
            content: [],
            pageControl: nil,
            animation: nil,
            interactionBehaviour: .default
        )

        package let pageWidth: Length
        package let pageHeight: Length
        package let pagePadding: EdgeInsets
        package let spacing: Double
        package let content: [Element]
        package let pageControl: PageControl?
        package let animation: Animation?
        package let interactionBehaviour: InteractionBehaviour
    }
}

extension AdaptyUI.Pager {
    package enum Length: Sendable {
        static let `default` = Length.parent(1)
        case fixed(AdaptyUI.Unit)
        case parent(Double)
    }

    package enum InteractionBehaviour: String {
        static let `default` = InteractionBehaviour.pauseAnimation
        case none
        case cancelAnimation
        case pauseAnimation
    }

    package struct PageControl: Hashable, Sendable {
        static let `default`: Self = .init(
            layout: .stacked,
            verticalAlignment: .bottom,
            padding: .init(same: .point(6)),
            dotSize: 6,
            spacing: 6,
            color: .same(AdaptyUI.Color.white),
            selectedColor: .same(AdaptyUI.Color.lightGray)
        )

        package enum Layout: String {
            case overlaid
            case stacked
        }

        package let layout: Layout
        package let verticalAlignment: AdaptyUI.VerticalAlignment
        package let padding: AdaptyUI.EdgeInsets
        package let dotSize: Double
        package let spacing: Double
        package let color: AdaptyUI.Mode<AdaptyUI.Color>
        package let selectedColor: AdaptyUI.Mode<AdaptyUI.Color>
    }

    package struct Animation: Hashable, Sendable {
        static let defaultStartDelay: TimeInterval = 0.0
        static let defaultAfterInteractionDelay: TimeInterval = 3.0

        package let startDelay: TimeInterval
        package let pageTransition: AdaptyUI.TransitionSlide
        package let repeatTransition: AdaptyUI.TransitionSlide?
        package let afterInteractionDelay: TimeInterval
    }
}

extension AdaptyUI.Pager.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(value)
        case let .parent(value):
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Pager {
        static func create(
            pageWidth: Length = `default`.pageWidth,
            pageHeight: Length = `default`.pageHeight,
            pagePadding: AdaptyUI.EdgeInsets = `default`.pagePadding,
            spacing: Double = `default`.spacing,
            content: [AdaptyUI.Element] = `default`.content,
            pageControl: PageControl? = `default`.pageControl,
            animation: Animation? = `default`.animation,
            interactionBehaviour: InteractionBehaviour = `default`.interactionBehaviour
        ) -> Self {
            .init(
                pageWidth: pageWidth,
                pageHeight: pageHeight,
                pagePadding: pagePadding,
                spacing: spacing,
                content: content,
                pageControl: pageControl,
                animation: animation,
                interactionBehaviour: interactionBehaviour
            )
        }
    }

    package extension AdaptyUI.Pager.PageControl {
        static func create(
            layout: Layout = `default`.layout,
            verticalAlignment: AdaptyUI.VerticalAlignment = `default`.verticalAlignment,
            padding: AdaptyUI.EdgeInsets = `default`.padding,
            dotSize: Double = `default`.dotSize,
            spacing: Double = `default`.spacing,
            color: AdaptyUI.Mode<AdaptyUI.Color> = `default`.color,
            selectedColor: AdaptyUI.Mode<AdaptyUI.Color> = `default`.selectedColor
        ) -> Self {
            .init(
                layout: layout,
                verticalAlignment: verticalAlignment,
                padding: padding,
                dotSize: dotSize,
                spacing: spacing,
                color: color,
                selectedColor: selectedColor
            )
        }
    }

    package extension AdaptyUI.Pager.Animation {
        static func create(
            startDelay: TimeInterval = defaultStartDelay,
            pageTransition: AdaptyUI.TransitionSlide = .create(),
            repeatTransition: AdaptyUI.TransitionSlide? = nil,
            afterInteractionDelay: TimeInterval = defaultAfterInteractionDelay
        ) -> Self {
            .init(
                startDelay: startDelay,
                pageTransition: pageTransition,
                repeatTransition: repeatTransition,
                afterInteractionDelay: afterInteractionDelay
            )
        }
    }
#endif

extension AdaptyUI.Pager.InteractionBehaviour: Decodable {
    package init(from decoder: Decoder) throws {
        self =
            switch try decoder.singleValueContainer().decode(String.self) {
            case "none": .none
            case "cancel_animation": .cancelAnimation
            case "pause_animation": .pauseAnimation
            default: .default
            }
    }
}

extension AdaptyUI.Pager.PageControl.Layout: Decodable {}

extension AdaptyUI.Pager.Animation: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case pageTransition = "page_transition"
        case repeatTransition = "repeat_transition"
        case afterInteractionDelay = "after_interaction_delay"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyUI.Pager.Animation.defaultStartDelay
        pageTransition = try container.decodeIfPresent(AdaptyUI.TransitionSlide.self, forKey: .pageTransition) ?? AdaptyUI.TransitionSlide.default
        repeatTransition = try container.decodeIfPresent(AdaptyUI.TransitionSlide.self, forKey: .repeatTransition)
        afterInteractionDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyUI.Pager.Animation.defaultAfterInteractionDelay
    }
}
