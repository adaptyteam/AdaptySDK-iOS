//
//  AdaptyUIPropertyAnimator.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 6/6/25.
//

#if canImport(UIKit)

import SwiftUI

extension VC.Animation.Timeline {
    // Native SwiftUI `repeatCount` snaps the property to the target value after the
    // last segment. For finite ping-pong that produces a visible jump to `end` instead
    // of resting on `start`, so we only allow native repeat where it lands correctly:
    // any normal loop without per-iteration gaps, or an infinite ping-pong where the
    // snap is never observed.
    fileprivate var canUseNativeRepeat: Bool {
        guard loopDelay == 0, !interpolator.usesCustomCurve else { return false }
        switch loop {
        case .pingPong: return loopCount == nil && pingPongDelay == 0
        case .normal: return true
        case .none: return false
        }
    }

    /// Time between the starts of two consecutive iterations of a loop.
    fileprivate var loopPeriod: TimeInterval {
        switch loop {
        case .pingPong: duration * 2 + pingPongDelay + loopDelay
        default: duration + loopDelay
        }
    }

    /// `completion` fires once a non-repeating animation has finished. Repeating
    /// animations have no end, so for them it fires right away.
    @MainActor
    func animate<Value>(
        from start: Value,
        to end: Value,
        completion: (() -> Void)? = nil,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        if loop != nil { completion?() }

        return switch loop {
        case .normal:
            if canUseNativeRepeat {
                AdaptyUIPropertyAnimator.animateWithNativeRepeat(
                    timeline: self,
                    startDelay: startDelay,
                    loopCount: loopCount,
                    autoreverses: false,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            } else {
                AdaptyUIPropertyAnimator.animateBasicLoop(
                    token: nil,
                    timeline: self,
                    startDelay: startDelay,
                    origin: .now() + startDelay,
                    loopCount: loopCount,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            }
        case .pingPong:
            if canUseNativeRepeat {
                AdaptyUIPropertyAnimator.animateWithNativeRepeat(
                    timeline: self,
                    startDelay: startDelay,
                    loopCount: nil,
                    autoreverses: true,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            } else {
                AdaptyUIPropertyAnimator.animatePingPongLoop(
                    token: nil,
                    timeline: self,
                    startDelay: startDelay,
                    origin: .now() + startDelay,
                    loopCount: loopCount,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            }
        default: // no repeat
            AdaptyUIPropertyAnimator.animateOnce(
                token: nil,
                timeline: self,
                startDelay: startDelay,
                from: start,
                to: end,
                updateBlock: updateBlock,
                completion: completion
            )
        }
    }

    @MainActor
    @discardableResult
    func withAsyncAnimation(
        token: AdaptyUIAnimationToken? = nil,
        delay: TimeInterval,
        onBeforeAnimation: (() -> Void)?,
        body: @escaping () -> Void,
        completion: @escaping (AdaptyUIAnimationToken) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = token ?? .create()
        let animation = interpolator.createAnimation(duration: duration)

        Task { @MainActor in
            try await Task.sleep(seconds: delay)

            guard token.isActive else {
                completion(token)
                return
            }

            onBeforeAnimation?()

            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                withAnimation(animation, body, completion: { completion(token) })
            } else {
                withAnimation(animation, body)
                try await Task.sleep(seconds: duration)
                completion(token)
            }
        }

        return token
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
    /// When the iteration after the one planned for `origin` starts. Loops are
    /// scheduled from their planned starts, not from the moment the previous
    /// iteration finished, so the time spent between completion callbacks does
    /// not accumulate and loops started a fixed time apart stay that far apart.
    /// An iteration that is already late starts right away and becomes the new
    /// origin: missed iterations are not replayed back to back.
    nonisolated static func nextIterationStart(
        after origin: DispatchTime,
        period: TimeInterval,
        now: DispatchTime = .now()
    ) -> DispatchTime {
        let planned = origin + period
        return planned < now ? now : planned
    }

    /// Runs `work` on the main queue at `deadline`. `asyncAfter` lets the system
    /// defer a timer by about a tenth of its delay and fire nearby timers
    /// together, which collapses loops meant to run with a fixed offset from each
    /// other into one.
    private static func run(at deadline: DispatchTime, _ work: @escaping @MainActor () -> Void) {
        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: .main)
        timer.schedule(deadline: deadline, leeway: .nanoseconds(0))
        timer.setEventHandler {
            timer.cancel()
            MainActor.assumeIsolated(work)
        }
        timer.resume()
    }

    @discardableResult
    static func animatePingPongLoop<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        origin: DispatchTime,
        loopCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let pingPongDelay = timeline.pingPongDelay

        return timeline.withAsyncAnimation(
            token: token,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: { token in
                guard token.isActive else { return }

                timeline.withAsyncAnimation(
                    token: token,
                    delay: pingPongDelay,
                    onBeforeAnimation: nil,
                    body: { updateBlock(start) },
                    completion: { token in
                        let loopLeftCount = (loopCount ?? .max) - 1

                        if loopLeftCount > 0 {
                            let next = nextIterationStart(after: origin, period: timeline.loopPeriod)
                            run(at: next) {
                                guard token.isActive else { return }

                                animatePingPongLoop(
                                    token: token,
                                    timeline: timeline,
                                    startDelay: 0.0,
                                    origin: next,
                                    loopCount: loopLeftCount,
                                    from: start,
                                    to: end,
                                    updateBlock: updateBlock
                                )
                            }
                        } else {
                            token.invalidate()
                        }
                    }
                )
            }
        )
    }

    @discardableResult
    static func animateBasicLoop<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        origin: DispatchTime,
        loopCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        timeline.withAsyncAnimation(
            token: token,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: { token in
                guard token.isActive else { return }

                let loopLeftCount = (loopCount ?? .max) - 1

                if loopLeftCount > 0 {
                    let next = nextIterationStart(after: origin, period: timeline.loopPeriod)
                    run(at: next) {
                        guard token.isActive else { return }

                        animateBasicLoop(
                            token: token,
                            timeline: timeline,
                            startDelay: 0.0,
                            origin: next,
                            loopCount: loopLeftCount,
                            from: start,
                            to: end,
                            updateBlock: updateBlock
                        )
                    }
                } else {
                    token.invalidate()
                }
            }
        )
    }

    @discardableResult
    static func animateWithNativeRepeat<Value>(
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        loopCount: Int?,
        autoreverses: Bool,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = AdaptyUIAnimationToken.create()
        let baseAnimation = timeline.interpolator.createAnimation(duration: timeline.duration)

        let animation: Animation
        if let loopCount {
            let count = autoreverses ? loopCount * 2 : loopCount
            animation = baseAnimation.repeatCount(count, autoreverses: autoreverses)
        } else {
            animation = baseAnimation.repeatForever(autoreverses: autoreverses)
        }

        Task { @MainActor in
            if startDelay > 0 {
                try await Task.sleep(seconds: startDelay)
                guard token.isActive else { return }
            }

            updateBlock(start)

            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                if loopCount != nil {
                    withAnimation(animation) {
                        updateBlock(end)
                    } completion: {
                        token.invalidate()
                    }
                } else {
                    withAnimation(animation) {
                        updateBlock(end)
                    }
                }
            } else {
                withAnimation(animation) {
                    updateBlock(end)
                }
                if let loopCount {
                    let totalSegments = autoreverses ? loopCount * 2 : loopCount
                    try await Task.sleep(seconds: timeline.duration * Double(totalSegments))
                    token.invalidate()
                }
            }
        }

        return token
    }

    static func animateOnce<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void,
        completion: (() -> Void)?
    ) -> AdaptyUIAnimationToken {
        timeline.withAsyncAnimation(
            token: nil,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: {
                $0.invalidate()
                completion?()
            }
        )
    }
}

#endif
