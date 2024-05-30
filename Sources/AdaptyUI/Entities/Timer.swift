//
//  Timer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Timer {
        static let defaultStartBehaviour = StartBehaviour.firstAppear

        package let id: String
        package let duration: TimeInterval
        package let startBehaviour: StartBehaviour
        package let format: [Item]

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

        init(id: String, duration: TimeInterval, startBehaviour: StartBehaviour, format: [Item]) {
            self.id = id
            self.duration = duration
            self.startBehaviour = startBehaviour
            self.format = format.sorted(by: { $0.from > $1.from })
        }

        package enum StartBehaviour {
            case everyAppear
            case firstAppear
            case firstAppearPersisted
            case specifiedTime(Date)
            case custom
        }

        package struct Item {
            package let from: TimeInterval
            package let value: RichText
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Timer {
        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehaviour: StartBehaviour = AdaptyUI.Timer.defaultStartBehaviour,
            format: AdaptyUI.RichText
        ) -> Self {
            .init(
                id: id,
                duration: duration,
                startBehaviour: startBehaviour,
                format: [.init(from: 0, value: format)]
            )
        }

        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehaviour: StartBehaviour = AdaptyUI.Timer.defaultStartBehaviour,
            format: [Item]
        ) -> Self {
            .init(
                id: id,
                duration: duration,
                startBehaviour: startBehaviour,
                format: format
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
