//
//  Timer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Timer: Sendable, Hashable {
        package let id: String
        package let state: State
        package let format: [Item]
        package let actions: [ActionAction]
        package let horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment

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

        init(id: String, state: State, format: [Item], actions: [ActionAction], horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment) {
            self.id = id
            self.state = state
            self.format = format.sorted(by: { $0.from > $1.from })
            self.actions = actions
            self.horizontalAlign = horizontalAlign
        }

        package enum State: Sendable {
            case endedAt(Date)
            case duration(TimeInterval, start: StartBehavior)
        }

        package enum StartBehavior: Sendable, Hashable {
            static let `default` = StartBehavior.firstAppear
            case everyAppear
            case firstAppear
            case firstAppearPersisted
            case custom
        }

        package struct Item: Sendable, Hashable {
            package let from: TimeInterval
            package let value: RichText
        }
    }
}

extension AdaptyViewConfiguration.Timer.State: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .endedAt(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .duration(value, start):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(start)
        }
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Timer {
        static func create(
            id: String = UUID().uuidString,
            endedAt: Date,
            format: AdaptyViewConfiguration.RichText,
            actions: [AdaptyViewConfiguration.ActionAction] = [],
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = .leading
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
            actions: [AdaptyViewConfiguration.ActionAction] = [],
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = .leading
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
            startBehavior: StartBehavior = .default,
            format: AdaptyViewConfiguration.RichText,
            actions: [AdaptyViewConfiguration.ActionAction] = [],
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = .leading
        ) -> Self {
            .create(
                id: id,
                duration: duration,
                startBehavior: startBehavior,
                format: [.init(from: 0, value: format)],
                actions: actions,
                horizontalAlign: horizontalAlign
            )
        }

        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehavior: StartBehavior = .default,
            format: [Item],
            actions: [AdaptyViewConfiguration.ActionAction] = [],
            horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment = .leading
        ) -> Self {
            .init(
                id: id,
                state: .duration(duration, start: startBehavior),
                format: format,
                actions: actions,
                horizontalAlign: horizontalAlign
            )
        }
    }

    package extension AdaptyViewConfiguration.Timer.Item {
        static func create(
            from: TimeInterval,
            value: AdaptyViewConfiguration.RichText
        ) -> Self {
            .init(
                from: from,
                value: value
            )
        }
    }
#endif
