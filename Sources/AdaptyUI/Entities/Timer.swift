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
        package let id: String
        package let duration: TimeInterval
        package let startBehaviour: StartBehaviour
        package let format: [Item]

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
            package let stringId: String
        }
    }
}

#if DEBUG
    package extension AdaptyUI.Timer {
        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehaviour: StartBehaviour = .firstAppear,
            format: String
        ) -> Self {
            .init(
                id: id,
                duration: duration,
                startBehaviour: startBehaviour,
                format: [.init(from: 0, stringId: format)]
            )
        }

        static func create(
            id: String = UUID().uuidString,
            duration: TimeInterval,
            startBehaviour: StartBehaviour = .firstAppear,
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
            stringId: String
        ) -> Self {
            .init(
                from: from,
                stringId: stringId
            )
        }
    }
#endif
