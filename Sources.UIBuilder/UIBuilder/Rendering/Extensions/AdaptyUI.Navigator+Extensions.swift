//
//  AdaptyUI.Navigator+Extensions.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 11/02/2026.
//

#if canImport(UIKit)

import Foundation

extension VC.Navigator.AppearanceTransition {
    var totalDuration: TimeInterval {
        let backgroundTimeline: [VC.Animation.Timeline] = if let background { [background.timeline] } else { [] }

        return
            (backgroundTimeline + (content?.map(\.timeline) ?? []))
                .map { $0.duration + $0.startDelay }
                .max() ?? 0.0
    }

    var initialContentOpacity: Double {
        content?
            .compactMap {
                if case let .opacity(range) = $0.kind {
                    return (timeline: $0.timeline, range: range)
                } else {
                    return nil
                }
            }
            .min(by: { lhs, rhs in lhs.timeline.startDelay < rhs.timeline.startDelay })
            .map { $0.range.start } ?? 1.0
    }

    var initialContentOffset: VC.Offset {
        content?
            .compactMap {
                if case let .offset(range) = $0.kind {
                    return (timeline: $0.timeline, range: range)
                } else {
                    return nil
                }
            }
            .min(by: { lhs, rhs in lhs.timeline.startDelay < rhs.timeline.startDelay })
            .map { $0.range.start } ?? .zero
    }
}

extension VC.Navigator.ScreenTransition {
    var totalDuration: TimeInterval {
        ((incoming ?? []) + (outgoing ?? [])).totalDuration
    }
}

#endif
