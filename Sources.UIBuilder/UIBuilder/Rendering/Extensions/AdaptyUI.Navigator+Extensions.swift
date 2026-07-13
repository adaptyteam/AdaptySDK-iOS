//
//  AdaptyUI.Navigator+Extensions.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 11/02/2026.
//

#if canImport(UIKit)

import Foundation

extension VC.Navigator {
    static let rtlSuffix = "@rtl"

    /// Resolves a screen transition by id, preferring the `@rtl` variant in
    /// right-to-left layouts and falling back to the base id. Mirrors the
    /// dark-mode asset resolution in `VS+Assets` (`[id + suffix]` → `[id]`).
    func screenTransition(id: String, isRightToLeft: Bool) -> ScreenTransition? {
        if isRightToLeft, let value = transitions?[id + Self.rtlSuffix] {
            return value
        }
        return transitions?[id]
    }

    /// Resolves an appearance transition by id, preferring the `@rtl` variant
    /// in right-to-left layouts and falling back to the base id.
    func appearanceTransition(id: String, isRightToLeft: Bool) -> AppearanceTransition? {
        if isRightToLeft, let value = appearances?[id + Self.rtlSuffix] {
            return value
        }
        return appearances?[id]
    }
}

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
