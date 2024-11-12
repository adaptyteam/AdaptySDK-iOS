//
//  Timer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUICore {
    package struct Timer: Sendable, Hashable {
        package let id: String
        package let state: State
        package let format: [Item]
        package let actions: [ActionAction]
        package let horizontalAlign: AdaptyUICore.HorizontalAlignment

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

        init(id: String, state: State, format: [Item], actions: [ActionAction], horizontalAlign: AdaptyUICore.HorizontalAlignment) {
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

        package enum StartBehaviour: Sendable, Hashable {
            static let `default` = StartBehaviour.firstAppear
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

extension AdaptyUICore.Timer.State: Hashable {
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
    package extension AdaptyUICore.Timer {
        static func create(
            id: String = UUID().uuidString,
            endedAt: Date,
            format: AdaptyUICore.RichText,
            actions: [AdaptyUICore.ActionAction] = [],
            horizontalAlign: AdaptyUICore.HorizontalAlignment = .leading
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
            actions: [AdaptyUICore.ActionAction] = [],
            horizontalAlign: AdaptyUICore.HorizontalAlignment = .leading
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
            format: AdaptyUICore.RichText,
            actions: [AdaptyUICore.ActionAction] = [],
            horizontalAlign: AdaptyUICore.HorizontalAlignment = .leading
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
            actions: [AdaptyUICore.ActionAction] = [],
            horizontalAlign: AdaptyUICore.HorizontalAlignment = .leading
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

    package extension AdaptyUICore.Timer.Item {
        static func create(
            from: TimeInterval,
            value: AdaptyUICore.RichText
        ) -> Self {
            .init(
                from: from,
                value: value
            )
        }
    }
#endif
