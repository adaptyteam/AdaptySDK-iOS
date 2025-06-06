//
//  AdaptyUIPropertyAnimator.swift
//  Adapty
//
//  Created by Alexey Goncharov on 6/6/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

extension AdaptyViewConfiguration.Animation.Timeline {
    @MainActor
    func animate<Value>(
        //        timeline: AdaptyViewConfiguration.Animation.Timeline,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        switch repeatType {
        case .reverse: // animate back
            AdaptyUIPropertyAnimator.animateWithReverseLoop(
                timeline: self,
                startDelay: startDelay,
                repeatMaxCount: repeatMaxCount,
                from: start,
                to: end,
                updateBlock: updateBlock
            )
        case .restart: // reset value and repeat
            AdaptyUIPropertyAnimator.animateWithRestart(
                timeline: self,
                startDelay: startDelay,
                repeatMaxCount: repeatMaxCount,
                from: start,
                to: end,
                updateBlock: updateBlock
            )
        default: // no repeat
            AdaptyUIPropertyAnimator.animateOnce(
                timeline: self,
                startDelay: startDelay,
                from: start,
                to: end,
                updateBlock: updateBlock
            )
        }
    }
}

typealias AdaptyUIAnimationToken = UUID

@MainActor
extension AdaptyUIAnimationToken {
    private static var storage = Set<UUID>()

    fileprivate static func create() -> Self {
        let token: Self = UUID()
        storage.insert(token)
        return token
    }

    var isActive: Bool {
        Self.storage.contains(self)
    }

    func invalidate() {
        Self.storage.remove(self)
    }
}

@MainActor
enum AdaptyUIPropertyAnimator {
    static func animateWithReverseLoop<Value>(
        token: AdaptyUIAnimationToken? = nil,
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        startDelay: TimeInterval,
        repeatMaxCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = token ?? .create()
        let duration = timeline.duration
        let repeatDelay = timeline.repeatDelay

        let animation: Animation = .linear(duration: duration) // TODO: implement interpolator

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            guard token.isActive else { return }

            updateBlock(start)

            withAnimation(animation) {
                updateBlock(end)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration + repeatDelay) {
                guard token.isActive else { return }

                withAnimation(animation) {
                    updateBlock(start)
                }

                let repeatMaxCount = repeatMaxCount ?? .max

                if repeatMaxCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration + repeatDelay) {
                        guard token.isActive else { return }

                        animateWithReverseLoop(
                            token: token,
                            timeline: timeline,
                            startDelay: 0.0,
                            repeatMaxCount: repeatMaxCount - 1,
                            from: start,
                            to: end,
                            updateBlock: updateBlock
                        )
                    }
                } else {
                    token.invalidate()
                }
            }
        }

        return token
    }

    static func animateWithRestart<Value>(
        token: AdaptyUIAnimationToken? = nil,
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        startDelay: TimeInterval,
        repeatMaxCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = token ?? .create()
        let duration = timeline.duration
        let repeatDelay = timeline.repeatDelay

        let animation: Animation = .linear(duration: duration) // TODO: implement interpolator

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            guard token.isActive else { return }

            updateBlock(start)

            withAnimation(animation) {
                updateBlock(end)
            }

            let repeatLeftCount = (repeatMaxCount ?? .max) - 1

            if repeatLeftCount > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration + repeatDelay) {
                    guard token.isActive else { return }

                    animateWithRestart(
                        token: token,
                        timeline: timeline,
                        startDelay: 0.0,
                        repeatMaxCount: repeatLeftCount,
                        from: start,
                        to: end,
                        updateBlock: updateBlock
                    )
                }
            } else {
                token.invalidate()
            }
        }

        return token
    }

    static func animateOnce<Value>(
        token: AdaptyUIAnimationToken? = nil,
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        startDelay: TimeInterval,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = token ?? .create()
        let duration = timeline.duration

        let animation: Animation = .linear(duration: duration) // TODO: implement interpolator

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            guard token.isActive else { return }

            updateBlock(start)

            withAnimation(animation) {
                updateBlock(end)
            }

//            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            token.invalidate()
//            }
        }

        return token
    }
}

#endif
