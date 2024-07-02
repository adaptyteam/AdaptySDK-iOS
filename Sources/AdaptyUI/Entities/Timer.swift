//
//  Timer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Timer: Hashable, Sendable {
        package let id: String
        package let state: State
        package let format: [Item]
        package let actions: [ActionAction]
        package let horizontalAlign: AdaptyUI.HorizontalAlignment

        package func format(byValue: TimeInterval) -> RichText {
            let index =
                if let index = format.firstIndex(where: { byValue > $0.from }) {
                    index > 0 ? index - 1 : index
                } else {
                    format.count - 1
                }
            guard format.indices.contains(index) else { return .empty }
            return format[index].value
        }

        init(id: String, state: State, format: [Item], actions: [ActionAction], horizontalAlign: AdaptyUI.HorizontalAlignment) {
            self.id = id
            self.state = state
            self.format = format.sorted(by: { $0.from > $1.from })
            self.actions = actions
            self.horizontalAlign = horizontalAlign
        }

        package enum State: Sendable {
            case endedAt(Date)
            case duration(TimeInterval, start: StartBehaviour)
        }

        package enum StartBehaviour {
            static let `default` = StartBehaviour.firstAppear
            case everyAppear
            case firstAppear
            case firstAppearPersisted
            case custom
        }

        package struct Item: Hashable, Sendable {
            package let from: TimeInterval
            package let value: RichText
        }
    }
}

extension AdaptyUI.Timer.State: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .endedAt(value):
            hasher.combine(value)
        case let .duration(value, start):
            hasher.combine(value)
            hasher.combine(start)
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Timer {
        static func create(
            id: String = UUID().uuidString,
            endedAt: Date,
            format: AdaptyUI.RichText,
            actions: [AdaptyUI.ActionAction] = [],
            horizontalAlign: AdaptyUI.HorizontalAlignment = .leading
        ) -> Self {
            .create(
                id: id,
                endedAt: endedAt,
                format: [.init(from: 0, value: format)],
                actions: actions,
                horizontalAlign: horizontalAlign
            )
        }

        static func create(
            id: String = UUID().uuidString,
            endedAt: Date,
            format: [Item],
            actions: [AdaptyUI.ActionAction] = [],
            horizontalAlign: AdaptyUI.HorizontalAlignment = .leading
        ) -> Self {
            .init(
                id: id,
                state: .endedAt(endedAt),
                format: format,
                actions: actions,
                horizontalAlign: horizontalAlign
            )
        }

        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehaviour: StartBehaviour = .default,
            format: AdaptyUI.RichText,
            actions: [AdaptyUI.ActionAction] = [],
            horizontalAlign: AdaptyUI.HorizontalAlignment = .leading
        ) -> Self {
            .create(
                id: id,
                duration: duration,
                startBehaviour: startBehaviour,
                format: [.init(from: 0, value: format)],
                actions: actions,
                horizontalAlign: horizontalAlign
            )
        }

        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehaviour: StartBehaviour = .default,
            format: [Item],
            actions: [AdaptyUI.ActionAction] = [],
            horizontalAlign: AdaptyUI.HorizontalAlignment = .leading
        ) -> Self {
            .init(
                id: id,
                state: .duration(duration, start: startBehaviour),
                format: format,
                actions: actions,
                horizontalAlign: horizontalAlign
            )
        }
    }

    package extension AdaptyUI.Timer.Item {
        static func create(
            from: TimeInterval,
            value: AdaptyUI.RichText
        ) -> Self {
            .init(
                from: from,
                value: value
            )
        }
    }
#endif
