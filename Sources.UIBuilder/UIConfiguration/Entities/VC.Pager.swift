//
//  VC.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

package extension VC {
    struct Pager: Sendable, Hashable {
        static let `default` = Pager(
            pageWidth: .default,
            pageHeight: .default,
            pagePadding: .zero,
            spacing: 0,
            content: [],
            pageControl: nil,
            animation: nil,
            interactionBehavior: .default
        )

        package let pageWidth: Length
        package let pageHeight: Length
        package let pagePadding: EdgeInsets
        package let spacing: Double
        package let content: [Element]
        package let pageControl: PageControl?
        package let animation: Animation?
        package let interactionBehavior: InteractionBehavior
    }
}

package extension VC.Pager {
    enum Length: Sendable {
        static let `default` = Length.parent(1)
        case fixed(VC.Unit)
        case parent(Double)
    }

    enum InteractionBehavior: String {
        static let `default` = InteractionBehavior.pauseAnimation
        case none
        case cancelAnimation = "cancel_animation"
        case pauseAnimation = "pause_animation"
    }

    struct PageControl: Sendable, Hashable {
        static let `default`: Self = .init(
            layout: .stacked,
            verticalAlignment: .bottom,
            padding: .init(same: .point(6)),
            dotSize: 6,
            spacing: 6,
            color: .same(VC.Color.white),
            selectedColor: .same(VC.Color.lightGray)
        )

        package enum Layout: String {
            case overlaid
            case stacked
        }

        package let layout: Layout
        package let verticalAlignment: VC.VerticalAlignment
        package let padding: VC.EdgeInsets
        package let dotSize: Double
        package let spacing: Double
        package let color: VC.Mode<VC.Color>
        package let selectedColor: VC.Mode<VC.Color>
    }

    struct Animation: Sendable, Hashable {
        static let defaultStartDelay: TimeInterval = 0.0
        static let defaultAfterInteractionDelay: TimeInterval = 3.0

        package let startDelay: TimeInterval
        package let pageTransition: VC.TransitionSlide
        package let repeatTransition: VC.TransitionSlide?
        package let afterInteractionDelay: TimeInterval
    }
}

extension VC.Pager.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .parent(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

#if DEBUG
package extension VC.Pager {
    static func create(
        pageWidth: Length = `default`.pageWidth,
        pageHeight: Length = `default`.pageHeight,
        pagePadding: VC.EdgeInsets = `default`.pagePadding,
        spacing: Double = `default`.spacing,
        content: [VC.Element] = `default`.content,
        pageControl: PageControl? = `default`.pageControl,
        animation: Animation? = `default`.animation,
        interactionBehaviour: InteractionBehavior = `default`.interactionBehavior
    ) -> Self {
        .init(
            pageWidth: pageWidth,
            pageHeight: pageHeight,
            pagePadding: pagePadding,
            spacing: spacing,
            content: content,
            pageControl: pageControl,
            animation: animation,
            interactionBehavior: interactionBehaviour
        )
    }
}

package extension VC.Pager.PageControl {
    static func create(
        layout: Layout = `default`.layout,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
        padding: VC.EdgeInsets = `default`.padding,
        dotSize: Double = `default`.dotSize,
        spacing: Double = `default`.spacing,
        color: VC.Mode<VC.Color> = `default`.color,
        selectedColor: VC.Mode<VC.Color> = `default`.selectedColor
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

package extension VC.Pager.Animation {
    static func create(
        startDelay: TimeInterval = defaultStartDelay,
        pageTransition: VC.TransitionSlide = .create(),
        repeatTransition: VC.TransitionSlide? = nil,
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

extension VC.Pager.InteractionBehavior: Codable {}

extension VC.Pager.PageControl.Layout: Codable {}

extension VC.Pager.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case pageTransition = "page_transition"
        case repeatTransition = "repeat_transition"
        case afterInteractionDelay = "after_interaction_delay"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? VC.Pager.Animation.defaultStartDelay
        pageTransition = try container.decodeIfPresent(VC.TransitionSlide.self, forKey: .pageTransition) ?? VC.TransitionSlide.default
        repeatTransition = try container.decodeIfPresent(VC.TransitionSlide.self, forKey: .repeatTransition)
        afterInteractionDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? VC.Pager.Animation.defaultAfterInteractionDelay
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if startDelay != Self.defaultStartDelay {
            try container.encode(startDelay * 1000, forKey: .startDelay)
        }
        try container.encode(pageTransition, forKey: .pageTransition)
        try container.encodeIfPresent(repeatTransition, forKey: .repeatTransition)
        if afterInteractionDelay != Self.defaultAfterInteractionDelay {
            try container.encode(afterInteractionDelay * 1000, forKey: .afterInteractionDelay)
        }
    }
}
